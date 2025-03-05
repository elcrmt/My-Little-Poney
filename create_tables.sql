-- 1. Modification de la table user existante
ALTER TABLE `user` 
ADD COLUMN IF NOT EXISTS `age` INT,
ADD COLUMN IF NOT EXISTS `ffe_profile_link` VARCHAR(255),
ADD COLUMN IF NOT EXISTS `is_dp` TINYINT(1) DEFAULT 0;

-- 2. Création de la table horse
CREATE TABLE IF NOT EXISTS `horse` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `age` INT,
  `color` VARCHAR(50),
  `breed` VARCHAR(100),
  `gender` ENUM('male', 'female', 'gelding'),
  `specialty` ENUM('dressage', 'jumping', 'endurance', 'eventing'),
  `photo` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Création de la table user_horse
CREATE TABLE IF NOT EXISTS `user_horse` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `horse_id` INT NOT NULL,
  `relationship_type` ENUM('owner', 'half_pension') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`horse_id`) REFERENCES `horse`(`id`) ON DELETE CASCADE
);

-- 4. Insertion de données de test dans la table horse
INSERT INTO `horse` (`name`, `age`, `color`, `breed`, `gender`, `specialty`, `photo`) VALUES
('Tornado', 8, 'Bai', 'Selle Français', 'gelding', 'jumping', 'tornado.jpg'),
('Étoile', 6, 'Alezan', 'Pur-sang', 'female', 'dressage', 'etoile.jpg'),
('Éclair', 10, 'Noir', 'Frison', 'male', 'eventing', 'eclair.jpg');

-- 5. Insertion de données de test dans la table user_horse
INSERT INTO `user_horse` (`user_id`, `horse_id`, `relationship_type`) VALUES
(4, 1, 'half_pension'),
(1, 2, 'owner'),
(3, 3, 'owner');

-- 6. Mise à jour de l'utilisateur "francois" avec des informations supplémentaires
UPDATE `user` 
SET `age` = 28, 
    `ffe_profile_link` = 'https://ffe.com/cavalier/francois123', 
    `is_dp` = 1 
WHERE `id` = 4;
