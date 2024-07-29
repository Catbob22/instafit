-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 14, 2024 at 08:27 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `instafit`
--

-- --------------------------------------------------------

--
-- Table structure for table `community`
--

CREATE TABLE `community` (
  `communityID` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `description` varchar(300) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `banner` varchar(2000) NOT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `community`
--

INSERT INTO `community` (`communityID`, `name`, `description`, `type`, `image`, `banner`, `featured`, `user_id`) VALUES
(1, 'Hiker', 'For people that like hiking', 'sport', 'hiking.webp', 'hiking-banner.jpg', 0, NULL),
(2, 'MMA', 'learn mixed martial arts', 'sport', 'mma.jpeg', 'mma-banner.jpg', 0, NULL),
(3, 'swimming', 'i love water', 'sport', 'swimming.jpg', 'swimming-banner.jpg', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `community_join_requests`
--

CREATE TABLE `community_join_requests` (
  `requestID` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `message` text DEFAULT NULL,
  `communityID` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `community_join_requests`
--

INSERT INTO `community_join_requests` (`requestID`, `name`, `email`, `message`, `communityID`, `date`) VALUES
(1, 'Yang Yuan', '23002655@myrp.edu.sg', 'i love hiking', 1, '2024-07-11 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

CREATE TABLE `contact` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contact`
--

INSERT INTO `contact` (`id`, `name`, `email`, `message`, `submitted_at`) VALUES
(1, 'gracie', 'yayay@gmail.com', 'hei', '2024-07-13 09:51:36'),
(2, 'jgggjvhj', 'mhvj@gg.com', 'jgvjvukyi', '2024-07-13 09:57:10');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `eventID` int(11) NOT NULL,
  `communityID` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `venue` varchar(2000) NOT NULL,
  `date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`eventID`, `communityID`, `title`, `description`, `venue`, `date`) VALUES
(1, 1, 'hiking mount everest', 'we are gonna hike mount everest', '90 corporation road', '2024-07-31'),
(2, 2, 'UFC 304', 'Leon edwards and Belal muhammad main event', 'Manchester, England.', '2024-07-28');

-- --------------------------------------------------------

--
-- Table structure for table `goal_setting`
--

CREATE TABLE `goal_setting` (
  `user_id` int(11) NOT NULL,
  `timeline` text DEFAULT NULL,
  `reminders` text DEFAULT NULL,
  `task_markers` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leaderboard`
--

CREATE TABLE `leaderboard` (
  `leaderboardID` int(11) NOT NULL,
  `communityID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `leaderboard`
--

INSERT INTO `leaderboard` (`leaderboardID`, `communityID`, `userID`, `points`, `name`) VALUES
(1, 1, 1, 1000, 'Yang Yuan');

-- --------------------------------------------------------

--
-- Table structure for table `mentee_requests`
--

CREATE TABLE `mentee_requests` (
  `request_id` int(11) NOT NULL,
  `mentee_id` int(11) DEFAULT NULL,
  `mentor_id` int(11) DEFAULT NULL,
  `request_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('pending','accepted','rejected') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mentee_requests`
--

INSERT INTO `mentee_requests` (`request_id`, `mentee_id`, `mentor_id`, `request_date`, `status`) VALUES
(1, 3, 1, '2024-07-12 01:36:46', 'pending'),
(4, 1, 1, '2024-07-12 03:04:25', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `mentors`
--

CREATE TABLE `mentors` (
  `mentor_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `expertise` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mentors`
--

INSERT INTO `mentors` (`mentor_id`, `user_id`, `expertise`, `bio`, `profile_image`) VALUES
(1, 4, 'MMA fighter', 'I can help you with your BJJ.', 'oliveira.png'),
(2, 9, 'Swimming', 'Olympic winner', 'joseph.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `mentorship`
--

CREATE TABLE `mentorship` (
  `mentorship_id` int(11) NOT NULL,
  `mentor_id` int(11) DEFAULT NULL,
  `mentee_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','completed') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mentorship`
--

INSERT INTO `mentorship` (`mentorship_id`, `mentor_id`, `mentee_id`, `start_date`, `end_date`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2024-07-01', '2024-07-25', 'active', '2024-07-12 03:09:12', '2024-07-12 03:09:12');

-- --------------------------------------------------------

--
-- Table structure for table `mentorship_sessions`
--

CREATE TABLE `mentorship_sessions` (
  `session_id` int(11) NOT NULL,
  `mentor_id` int(11) DEFAULT NULL,
  `mentee_id` int(11) DEFAULT NULL,
  `session_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `posts`
--

CREATE TABLE `posts` (
  `post_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `posts`
--

INSERT INTO `posts` (`post_id`, `user_id`, `title`, `description`, `image`, `date`) VALUES
(1, 1, 'My first run', 'so hot', 'fit2.jfif', '2024-07-08 14:46:59'),
(2, 2, 'climbing mount everest', 'easiest walk of my life', 'fit3.jfif', '2024-07-08 14:51:26'),
(3, 2, 'my fav ko pic', 'this was sad yet funny', 'tonykod.webp', '2024-07-08 14:57:19'),
(5, 2, 'arman\'s physqiue is crazy', 'hi', 'arman.JPG', '2024-07-13 08:46:10');

-- --------------------------------------------------------

--
-- Table structure for table `progress_tracking`
--

CREATE TABLE `progress_tracking` (
  `user_id` int(11) NOT NULL,
  `workout_routine` text DEFAULT NULL,
  `meal_plans` text DEFAULT NULL,
  `wellness_posts` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `profile_image` varchar(255) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(200) NOT NULL,
  `bio` varchar(200) NOT NULL,
  `isMentor` tinyint(1) NOT NULL,
  `communityID` int(11) DEFAULT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `profile_image`, `username`, `email`, `bio`, `isMentor`, `communityID`, `password`) VALUES
(1, 'arman.JPG', 'Yang Yuan', '23002655@myrp.edu.sg', 'live fast die young', 0, NULL, '$2a$10$rK/1qWXwzxSiDuHbGmH1LeYOB6vDjm9bGVgsX7Yjjp1zibZXprb4q'),
(2, 'yy.jpg', 'poopboy', 'poopboy69@gmail.com', 'i love pooping', 1, NULL, '$2a$10$6W31olZMQXcmEt.yI.ZSju4Tusbd0VEBmRMJ3Op.8jdCKuV.skgC.'),
(3, 'mentee.jpg', 'menteeUser', 'mentee@example.com', 'Mentee bio', 0, NULL, ''),
(4, 'oliveira.png', 'Charles Oliveira', 'mentor@example.com', 'Mentor bio', 1, NULL, ''),
(9, 'jos.webp', 'Joseph Schooling', 'Josephschooling@gmail.com', 'Olympic winner', 0, NULL, '$2a$10$cj1PImMnv6PCoTuCkUvi/esN50NaOyR6hEN7v3XRtT0Ay8KCsTrAu');

-- --------------------------------------------------------

--
-- Table structure for table `user_community`
--

CREATE TABLE `user_community` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `communityID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_community`
--

INSERT INTO `user_community` (`id`, `user_id`, `communityID`) VALUES
(2, 2, 2),
(3, 1, 2),
(4, 9, 3),
(5, 2, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `community`
--
ALTER TABLE `community`
  ADD PRIMARY KEY (`communityID`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `community_join_requests`
--
ALTER TABLE `community_join_requests`
  ADD PRIMARY KEY (`requestID`),
  ADD KEY `communityID` (`communityID`);

--
-- Indexes for table `contact`
--
ALTER TABLE `contact`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`eventID`),
  ADD KEY `communityID` (`communityID`);

--
-- Indexes for table `goal_setting`
--
ALTER TABLE `goal_setting`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `leaderboard`
--
ALTER TABLE `leaderboard`
  ADD PRIMARY KEY (`leaderboardID`),
  ADD KEY `communityID` (`communityID`),
  ADD KEY `userID` (`userID`);

--
-- Indexes for table `mentee_requests`
--
ALTER TABLE `mentee_requests`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `mentee_id` (`mentee_id`),
  ADD KEY `mentor_id` (`mentor_id`);

--
-- Indexes for table `mentors`
--
ALTER TABLE `mentors`
  ADD PRIMARY KEY (`mentor_id`),
  ADD KEY `fk_mentors_users` (`user_id`);

--
-- Indexes for table `mentorship`
--
ALTER TABLE `mentorship`
  ADD PRIMARY KEY (`mentorship_id`),
  ADD KEY `mentor_id` (`mentor_id`),
  ADD KEY `mentee_id` (`mentee_id`);

--
-- Indexes for table `mentorship_sessions`
--
ALTER TABLE `mentorship_sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `mentor_id` (`mentor_id`),
  ADD KEY `mentee_id` (`mentee_id`);

--
-- Indexes for table `posts`
--
ALTER TABLE `posts`
  ADD PRIMARY KEY (`post_id`),
  ADD KEY `userId` (`user_id`);

--
-- Indexes for table `progress_tracking`
--
ALTER TABLE `progress_tracking`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `fk_community` (`communityID`);

--
-- Indexes for table `user_community`
--
ALTER TABLE `user_community`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `communityID` (`communityID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `community`
--
ALTER TABLE `community`
  MODIFY `communityID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `community_join_requests`
--
ALTER TABLE `community_join_requests`
  MODIFY `requestID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `contact`
--
ALTER TABLE `contact`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `eventID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `leaderboard`
--
ALTER TABLE `leaderboard`
  MODIFY `leaderboardID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mentee_requests`
--
ALTER TABLE `mentee_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `mentors`
--
ALTER TABLE `mentors`
  MODIFY `mentor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `mentorship`
--
ALTER TABLE `mentorship`
  MODIFY `mentorship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `mentorship_sessions`
--
ALTER TABLE `mentorship_sessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `posts`
--
ALTER TABLE `posts`
  MODIFY `post_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user_community`
--
ALTER TABLE `user_community`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `community`
--
ALTER TABLE `community`
  ADD CONSTRAINT `community_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `community_join_requests`
--
ALTER TABLE `community_join_requests`
  ADD CONSTRAINT `community_join_requests_ibfk_1` FOREIGN KEY (`communityID`) REFERENCES `community` (`communityID`);

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `events_ibfk_1` FOREIGN KEY (`communityID`) REFERENCES `community` (`communityID`);

--
-- Constraints for table `goal_setting`
--
ALTER TABLE `goal_setting`
  ADD CONSTRAINT `goal_setting_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `leaderboard`
--
ALTER TABLE `leaderboard`
  ADD CONSTRAINT `leaderboard_ibfk_1` FOREIGN KEY (`communityID`) REFERENCES `community` (`communityID`),
  ADD CONSTRAINT `leaderboard_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `mentee_requests`
--
ALTER TABLE `mentee_requests`
  ADD CONSTRAINT `mentee_requests_ibfk_1` FOREIGN KEY (`mentee_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `mentee_requests_ibfk_2` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`);

--
-- Constraints for table `mentors`
--
ALTER TABLE `mentors`
  ADD CONSTRAINT `fk_mentors_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `mentors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `mentorship`
--
ALTER TABLE `mentorship`
  ADD CONSTRAINT `mentorship_ibfk_1` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`),
  ADD CONSTRAINT `mentorship_ibfk_2` FOREIGN KEY (`mentee_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `mentorship_sessions`
--
ALTER TABLE `mentorship_sessions`
  ADD CONSTRAINT `mentorship_sessions_ibfk_1` FOREIGN KEY (`mentor_id`) REFERENCES `mentors` (`mentor_id`),
  ADD CONSTRAINT `mentorship_sessions_ibfk_2` FOREIGN KEY (`mentee_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `posts`
--
ALTER TABLE `posts`
  ADD CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `progress_tracking`
--
ALTER TABLE `progress_tracking`
  ADD CONSTRAINT `progress_tracking_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_community` FOREIGN KEY (`communityID`) REFERENCES `community` (`communityID`);

--
-- Constraints for table `user_community`
--
ALTER TABLE `user_community`
  ADD CONSTRAINT `user_community_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `user_community_ibfk_2` FOREIGN KEY (`communityID`) REFERENCES `community` (`communityID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
