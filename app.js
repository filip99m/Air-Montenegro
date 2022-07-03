var express = require("express");             
var app = express();
var mysql = require("mysql");
var bodyParser = require("body-parser");
var session = require("express-session");

var connection = mysql.createConnection({          // konekcija prema bazi
  host: "localhost",
  user: "root",
  password: "",
  database: "airline"
});

connection.connect(function(err) {                // ako je konekcija neuspjesna javlja se greska, u suprotnom konzologuje se Connected to MYSQL!
  if (err) throw err;
  console.log("Connected to MYSQL!");
});

app.use(express.static("assets"));                 // importovanje assets, css, js, ejs
app.use(express.static("css"));
app.use(express.static("js"));
app.set("view engine", "ejs");
app.use(bodyParser.urlencoded({ extended: true }));
app.use(
  session({ secret: "dbmsProject", resave: false, saveUninitialized: false })
);

app.get("/", function(req, res) {                   // rutiranje na home page
  if (req.session.email) {
    res.redirect("/home");
  } else {
    res.render("home");
  }
});

app.get("/login", function(req, res) {              // rutiranje na home page ako korisnik nije logovan
  if (req.session.email) {
    res.redirect("/home");
  } else {
    res.render("home");
  }
});

app.get("/register", function(req, res) {           // rutiranje na register endpoint
  res.render("register");
});

app.get("/home",isLoggedIn, function(req, res) {    // ako je korisnik ulogovan, sa home page-a se redirektuje na search
  res.render("search");
});

// ako je korisnik logovan prikazuje se search endpoint gdje korisnik unosi podatke za let koji se zatim pretrazuju 

app.get("/search",isLoggedIn, function(req, res) {  
  var r = (req.session.search = req.query);
  var from = r.from;
  var to = r.to;
  var date = r.date;
  var class_type = r.class;
  var noofppl = r.noofppl;
  req.session.noofppl = noofppl;
  var sql =
    "select l.logo," +
    noofppl +
    "*c." +
    class_type +
    " as price,a1.airport_code as from_code,a1.airport_name as from_name,a2.airport_code as to_code,a2.airport_name as to_name,l.airline_name,f.flight_no,TIME(f.departure_time) as departure_time,TIME(f.arrival_time) as arrival_time from airports as a1, airports as a2, airlines as l, flights as f,costs as c where l.airline_id=f.airline_id and f.from_airport_code=a1.airport_code and f.to_airport_code=a2.airport_code and c.airline_id = l.airline_id and from_airport_code='" +
    from +
    "' and to_airport_code = '" +
    to +
    "' and DATE(departure_time)='" +
    date +
    "' and f.seats_left_" +
    class_type +
    ">=" +
    noofppl;
  connection.query(sql, function(err, result) {
    if (err) {                                        // ako postoji greska sa bazom onda se konzologuje 
      console.log(err);
    } else {                                          // u suprotnom se redirektuje na endpoint flights sa pretrazenim rezultatima
      req.session.message = result;
      res.redirect("/flights");
    }
  });
});

app.get("/flights",isLoggedIn, function(req, res) {   // prikaz rezultata pretrazivanja
  var flights = req.session.message;
  res.render("results", { flights: flights });
});

app.get("/test", function(req, res) {                 // potvrda rezervacije
  res.render("confirmbooking");
});

// kada se izabere let sa odredjenim ID-em bira se broj putnika i podaci o njima i redirektuje se na endpoint passenger
app.get("/book/:flight_id",isLoggedIn, function(req, res) {
  req.session.fid = req.params.flight_id;
  req.session.f = 1;
  req.session.passengers = [];
  res.redirect("/passenger");
});

// ako nijesu uneseni podaci bar o jednom putniku, ponovo se redirektuje na endpoint passenger, u suprotnom ide se na endpoint confirmbooking
app.get("/passenger",isLoggedIn, function(req, res) {
  var n = req.session.noofppl;
  var f = req.session.f;
  if (f <= n) {
    res.render("passenger", { n: f });
  } else {
    res.redirect("/confirmbooking");
  }
});

// kada se podje na logout iz sesije se email postavlja na prazan string i korisnik se redirektuje na login page
app.get("/logout", function(req, res) {
  req.session.email = "";
  res.redirect("/login");
});

// kada smo dosli GET metodom do endpoint confirmbooking insertujemo podatke pretrage u bazu podataka, kao i podatke o putnicima
app.get("/confirmbooking",isLoggedIn, function(req, res) {
  var id;
  var search = req.session.search;
  var d = new Date();
  var date = d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
  var bookingsql =
    "INSERT INTO bookings(customer_email,no_of_seats,flight_no,booking_date,class_type) values ('" +
    req.session.email +
    "' , '" +
    search.noofppl +
    "' , '" +
    req.session.fid +
    "' , '" +
    date +
    "', '" +
    search.class +
    "')";
  connection.query(bookingsql, function(err, result) {
    if (err) {
      console.log(err);
    } else {
      id = result.insertId;
      ps = [];
      req.session.passengers.forEach(async function(p) {
        var checksql = "CALL checkbookings('" + p.name + "')";
        await connection.query(checksql, function(err, flagres) {
          if (err) {
            console.log(err);
          } else {
            var flag = flagres[0][0].len;
            console.log(flag);
            if (flag == 0) {
              var ip =
                "INSERT INTO passenger values(" +
                id +
                ",'" +
                p.name +
                "','" +
                p.gender +
                "'," +
                p.age +
                ")";
              console.log(ip);
              connection.query(ip);
            }
          }
        });
      });
      res.send("Booking Confirmed");
    }
  });
});

// dodavanje jos jednog putnika
app.post("/passenger",isLoggedIn, function(req, res) {
  req.session.f++;
  req.session.passengers.push(req.body);
  res.redirect("/passenger");
});

// login forma i proces logovanja 
app.post("/login", function(req, res) {
  var body = req.body;
  var email = body.email;
  var pass = body.pass;
  var getPass = "SELECT password FROM login WHERE email='" + email + "'";

  connection.query(getPass, function(err, result, fields) {
    if (err) {
      console.log(err);
    } else {
      if (result.length == 0) {
        res.redirect("/login");
      } else {
        var dbpass = result[0].password;
        if (pass == dbpass) {
          req.session.email = email;
          res.redirect("/home");
        } else {
          res.redirect("/login");
        }
      }
    }
  });
});

// registracija korisnika i unosenje podataka u bazu
app.post("/register", function(req, res) {
  var body = req.body;
  var email = body.email;
  var pass = body.pass;
  var name = body.name;
  var age = body.age;
  var gender = body.gender;

  var sql = "INSERT INTO login VALUES('" + email + "','" + pass + "')";
  var datasql =
    "INSERT INTO user VALUES('" +
    email +
    "','" +
    name +
    "'," +
    age +
    ",'" +
    gender +
    "')";
  connection.query(sql, function(err, result) {
    connection.query(datasql, function(ierr, iresult) {
      if (ierr) throw ierr;
      console.log(iresult);
      res.redirect("/login");
    });
  });
});

// konzollogovanje poruke Server has started at http://localhost:8080, kada se pokrene aplikacija na port 8080
app.listen(8080, function() {
  console.log("Server has started at http://localhost:8080");
});

// funkcija za provjeru da li je korisnik logovan
function isLoggedIn(req, res, next) {
  if (req.session.email) {
    return next();
  }
  res.redirect("/login");
}