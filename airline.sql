-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 26, 2022 at 11:48 PM
-- Server version: 10.4.17-MariaDB
-- PHP Version: 8.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `airline`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkbookings` (IN `name` VARCHAR(40))  BEGIN
select count(*) as len from passenger where customer_name=name;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `airlines`
--

CREATE TABLE `airlines` (
  `airline_id` varchar(10) NOT NULL,
  `airline_name` varchar(25) DEFAULT NULL,
  `logo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `airlines`
--

INSERT INTO `airlines` (`airline_id`, `airline_name`, `logo`) VALUES
('AIR001', 'Air Montenegro', 'https://airmontenegro.com/img/airmontenegro-logo.svg'),
('AIR002', 'Air Serbia', 'https://www.airserbia.com/img/logo/airserbia_logo_navy.svg');

-- --------------------------------------------------------

--
-- Table structure for table `airports`
--

CREATE TABLE `airports` (
  `airport_code` varchar(25) NOT NULL,
  `airport_name` varchar(50) DEFAULT NULL,
  `country` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `airports`
--

INSERT INTO `airports` (`airport_code`, `airport_name`, `country`) VALUES
('BEG', 'Nikola Tesla Airport', 'Serbia'),
('TGD', 'Podgorica Airport', 'Montenegro');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(25) NOT NULL,
  `customer_email` varchar(50) DEFAULT NULL,
  `no_of_seats` int(11) DEFAULT NULL,
  `flight_no` varchar(25) DEFAULT NULL,
  `booking_date` date DEFAULT NULL,
  `class_type` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `customer_email`, `no_of_seats`, `flight_no`, `booking_date`, `class_type`) VALUES
(3, 'filip123@gmail.com', 1, 'MNE102', '2022-06-26', 'economy'),
(18, 'filip123@gmail.com', 1, 'MNE102', '2022-06-26', 'economy');

--
-- Triggers `bookings`
--
DELIMITER $$
CREATE TRIGGER `bookdup` AFTER INSERT ON `bookings` FOR EACH ROW BEGIN
DECLARE type_of_seat varchar(25);
DECLARE nos int(11);
DECLARE bk_id int(11);
select class_type into type_of_seat from bookings order by booking_id DESC LIMIT 1;
select no_of_seats into nos from bookings order by booking_id DESC LIMIT 1;
select booking_id into bk_id from bookings order by booking_id DESC LIMIT 1;

IF type_of_seat = 'business' THEN
UPDATE flights,bookings set seats_left_business = seats_left_business - nos where bookings.flight_no = flights.flight_no and bookings.booking_id = bk_id;
ELSE
UPDATE flights,bookings set seats_left_economy = seats_left_economy - nos where bookings.flight_no = flights.flight_no and bookings.booking_id = bk_id;
END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `costs`
--

CREATE TABLE `costs` (
  `airline_id` varchar(25) DEFAULT NULL,
  `economy` int(11) DEFAULT NULL,
  `business` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `costs`
--

INSERT INTO `costs` (`airline_id`, `economy`, `business`) VALUES
('AIR001', 90, 160),
('AIR002', 110, 200);

-- --------------------------------------------------------

--
-- Table structure for table `flights`
--

CREATE TABLE `flights` (
  `flight_no` varchar(25) NOT NULL,
  `from_airport_code` varchar(25) DEFAULT NULL,
  `to_airport_code` varchar(25) DEFAULT NULL,
  `airline_id` varchar(25) DEFAULT NULL,
  `departure_time` datetime DEFAULT NULL,
  `arrival_time` datetime DEFAULT NULL,
  `seats_left_economy` int(5) DEFAULT NULL,
  `seats_left_business` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `flights`
--

INSERT INTO `flights` (`flight_no`, `from_airport_code`, `to_airport_code`, `airline_id`, `departure_time`, `arrival_time`, `seats_left_economy`, `seats_left_business`) VALUES
('MNE102', 'TGD', 'BEG', 'AIR001', '2022-06-22 06:00:00', '2022-06-22 06:45:00', 27, 19),
('MNE119', 'TGD', 'BEG', 'AIR001', '2022-07-03 21:00:00', '2022-07-03 21:46:00', 100, 250),
('SRB103', 'BEG', 'TGD', 'AIR002', '2022-06-25 09:00:00', '2022-06-25 09:45:00', 50, 17);

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `email` varchar(50) NOT NULL,
  `password` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`email`, `password`) VALUES
('filip123@gmail.com', 'filip123'),
('jusuf@jusuf.com', '3721');

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger` (
  `booking_id` int(25) DEFAULT NULL,
  `customer_name` varchar(25) DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `age` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`booking_id`, `customer_name`, `gender`, `age`) VALUES
(3, 'Filip', 'u', 10);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `email` varchar(50) NOT NULL,
  `name` varchar(30) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` char(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`email`, `name`, `age`, `gender`) VALUES
('filip123@gmail.com', 'Filip Marijanovic', 23, 'M'),
('jusuf@jusuf.com', 'Jusuf', 23, 'M');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `airlines`
--
ALTER TABLE `airlines`
  ADD PRIMARY KEY (`airline_id`);

--
-- Indexes for table `airports`
--
ALTER TABLE `airports`
  ADD PRIMARY KEY (`airport_code`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `customer_email` (`customer_email`),
  ADD KEY `flight_no` (`flight_no`);

--
-- Indexes for table `costs`
--
ALTER TABLE `costs`
  ADD KEY `airline_id` (`airline_id`);

--
-- Indexes for table `flights`
--
ALTER TABLE `flights`
  ADD PRIMARY KEY (`flight_no`),
  ADD KEY `from_airport_code` (`from_airport_code`),
  ADD KEY `to_airport_code` (`to_airport_code`),
  ADD KEY `airline_id` (`airline_id`);

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(25) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`customer_email`) REFERENCES `login` (`email`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`flight_no`) REFERENCES `flights` (`flight_no`) ON DELETE CASCADE;

--
-- Constraints for table `costs`
--
ALTER TABLE `costs`
  ADD CONSTRAINT `costs_ibfk_1` FOREIGN KEY (`airline_id`) REFERENCES `airlines` (`airline_id`) ON DELETE CASCADE;

--
-- Constraints for table `flights`
--
ALTER TABLE `flights`
  ADD CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`from_airport_code`) REFERENCES `airports` (`airport_code`) ON DELETE CASCADE,
  ADD CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`to_airport_code`) REFERENCES `airports` (`airport_code`) ON DELETE CASCADE,
  ADD CONSTRAINT `flights_ibfk_3` FOREIGN KEY (`airline_id`) REFERENCES `airlines` (`airline_id`) ON DELETE CASCADE;

--
-- Constraints for table `passenger`
--
ALTER TABLE `passenger`
  ADD CONSTRAINT `passenger_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE;

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`email`) REFERENCES `login` (`email`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
