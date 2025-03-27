CREATE TABLE Guild (
    name VARCHAR(16) PRIMARY KEY, 
    memberCount INTEGER, 
    description VARCHAR(255) 
);

CREATE TABLE PlayerJoins ( 
    accountID INTEGER PRIMARY KEY,
    username VARCHAR(16) UNIQUE,
    email VARCHAR(255), 
    createDate DATE, 
    role VARCHAR(255), 
    guildName VARCHAR(16) NULL, 
    FOREIGN KEY (guildName) REFERENCES Guild(name) 
);

CREATE TABLE Befriends (
    account1ID INTEGER,
    account2ID INTEGER,
    friendshipLevel INTEGER,
    PRIMARY KEY (account1ID, account2ID),
    FOREIGN KEY (account1ID) REFERENCES PlayerJoins(accountID), 
    FOREIGN KEY (account2ID) REFERENCES PlayerJoins(accountID)
);	

CREATE TABLE Mission ( 
    missionID INTEGER PRIMARY KEY, 
    requirement VARCHAR(255), 
    reward VARCHAR(255)
);

CREATE TABLE Completes ( 
    accountID INTEGER, 
    missionID INTEGER, 
    completionTimestamp DATE, 
    PRIMARY KEY (accountID, missionID), 
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID), 
    FOREIGN KEY (missionID) REFERENCES Mission(missionID) 
);

CREATE TABLE Item (
    name VARCHAR(30) PRIMARY KEY, 
    description VARCHAR(64)
);

CREATE TABLE ConsumableStat ( 
    rarity VARCHAR(16), 
    stat INTEGER, 
    boostType VARCHAR(8), 
    PRIMARY KEY (rarity, boostType) 
);

CREATE TABLE Consumable ( 
    name VARCHAR(16), 
    count INTEGER, 
    rarity VARCHAR(16), 
    boostType VARCHAR(8), 
    PRIMARY KEY (name), 
    FOREIGN KEY (name) REFERENCES Item(name)
);

CREATE TABLE Collectible (
    name VARCHAR(16),
    obtainedFrom VARCHAR(255), 
    PRIMARY KEY (name), 
    FOREIGN KEY (name) REFERENCES Item(name) 
);

CREATE TABLE Owns ( 
    accountID INTEGER, 
    name VARCHAR(16), 
    PRIMARY KEY (accountID, name), 
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID), 
    FOREIGN KEY (name) REFERENCES Item(name) 
);

CREATE TABLE CharacterStats ( 
    characterLevel INTEGER, 
    attack INTEGER, 
    defence INTEGER, 
    class VARCHAR(8), 
    PRIMARY KEY (characterLevel, class) 
);

CREATE TABLE CreatesCharacter ( 
    name VARCHAR(16) PRIMARY KEY, 
    characterLevel INTEGER, 
    class VARCHAR(10),
    playerID INTEGER UNIQUE NOT NULL, 
    FOREIGN KEY (playerID) REFERENCES PlayerJoins(accountID) 
);

CREATE TABLE ArmourName (
    name VARCHAR(16) PRIMARY KEY,
    rarity VARCHAR(16), 
    equipType VARCHAR(8), 
    boostType VARCHAR(8)
);


CREATE TABLE ArmourStat ( 
    rarity VARCHAR(16), 
    stat INTEGER, 
    boostType VARCHAR(8), 
    equipType VARCHAR(8), 
    PRIMARY KEY (rarity, boostType, equipType) 
);

CREATE TABLE CraftsArmour (
    armourID INTEGER PRIMARY KEY, 
    name VARCHAR(16), 
    boostType VARCHAR(8),
    accountID INTEGER NOT NULL, 
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID) 
);

CREATE TABLE Equips (
    armourID INTEGER PRIMARY KEY, 
    characterName VARCHAR(16), 
    FOREIGN KEY (armourID) REFERENCES CraftsArmour(armourID),
    FOREIGN KEY (characterName) REFERENCES CreatesCharacter(name) 
);

CREATE TABLE LearnsSkill (
    name VARCHAR(255) PRIMARY KEY, 
    effect VARCHAR(64), 
    characterName VARCHAR(16), 
    FOREIGN KEY (characterName) REFERENCES CreatesCharacter(name) 
);

CREATE TABLE QuestLocation ( 
    location VARCHAR(255), 
    bossCharacter VARCHAR(255) PRIMARY KEY  
);

CREATE TABLE QuestInfo ( 
    questID INTEGER PRIMARY KEY, 
    bossCharacter VARCHAR(255)
);

CREATE TABLE HaveStage ( 
    stageID INTEGER PRIMARY KEY, 
    objective VARCHAR(255), 
    questID INTEGER, 
    FOREIGN KEY (questID) REFERENCES QuestInfo(questID) 
);

CREATE TABLE Challenges ( 
    characterName VARCHAR(16), 
    questID INTEGER, 
    attemptTimestamp DATE, 
    PRIMARY KEY (characterName, questID), 
    FOREIGN KEY (characterName) REFERENCES CreatesCharacter(name), 
    FOREIGN KEY (questID) REFERENCES QuestInfo(questID)
);

CREATE SEQUENCE player_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

INSERT INTO Guild
VALUES
('Goats Guild', 3, 'A guild for goats all around the world'), 
('Best Players', 2, 'Only the best players are in this guild'), 
('Guild 1', 1, 'guild 1 description'), 
('Guild 2', 1, 'guild 2 description'), 
('Guild 3', 1, 'guild 3 description');

INSERT INTO PlayerJoins 
VALUES
(1, 'playerone', 'iplaygames@email.com', '2025-01-01', 'member', 'Best Players'), 
(2, 'thegoat', 'goatedgamer@email.com', '2025-01-05', 'leader', 'Goats Guild'), 
(3, 'legoat', 'goatedgamer@email.com', '2025-02-05', 'deputy', 'Goats Guild'), 
(4, 'dabest', 'bestest@email.com', '2025-02-20', 'leader', 'Best Players'), 
(5, 'mountaingoat', 'mountaingoat@email.com', '2025-02-21', 'member', 'Goats Guild'), 
(6, 'solo', 'soloplayer@email.com', '2025-02-22', NULL, NULL), 
(7, 'lesunshine', 'a@gmail.com', '2025-02-22', 'leader', 'Guild 1'), 
(8, 'lebron', 'b@gmail.com', '2025-02-22', 'leader', 'Guild 2'),
(9, 'leGM', 'c@gmail.com', '2025-02-22', 'leader', 'Guild 3');

INSERT INTO Befriends
VALUES
(1, 2, 10), 
(2, 3, 23), 
(2, 5, 5), 
(3, 5, 1), 
(7, 8, 5);

INSERT INTO Mission
VALUES
(101, 'kill 3 monsters', '10 coins'), 
(102, 'defeat a boss character', 'crown'), 
(103, 'add a friend', 'friendship bracelet'), 
(104, 'finish all quests', '100000 coins'),
(105, 'finish first quest', '10 coins');

INSERT INTO Completes
VALUES
(1, 101, '2025-01-01 15:30:10'), 
(1, 102, '2025-01-01 15:35:33'), 
(1, 103, '2025-01-05 22:00:05'), 
(2, 104, '2025-01-01 13:35:33'), 
(3, 104, '2025-01-05 20:00:05');

INSERT INTO Item
VALUES
('Bracelet', 'A token of your friendship'), 
('Crown', 'Reward for defeating your first boss'), 
('Ancient Coin', 'A rare coin from ancient times'),
('Golden Feather', 'A shimmering feather from a rare bird'),
('Dragon Scale', 'A tough scale from a defeated dragon'),
('Sandwich', 'A tasty sandwich that boosts attack'),
('Strength potion', 'A potion that increases your strength temporarily'),
('Healing Herb', 'A magical herb that restores health'),
('Energy Drink', 'A beverage that restores stamina'),
('Elixir of Wisdom', 'A rare potion that increases mana');

INSERT INTO ConsumableStat
VALUES
('common', 2, 'attack'), 
('common', 4, 'defence'), 
('rare', 5, 'attack'), 
('rare', 8, 'defence'), 
('legendary', 10, 'attack');

INSERT INTO Consumable
VALUES
('Sandwich', 5, 'common', 'attack'), 
('Strength potion', 2, 'rare', 'attack'), 
('Healing Herb', 3, 'uncommon', 'health'), 
('Energy Drink', 4, 'common', 'stamina'), 
('Elixir of Wisdom', 1, 'legendary', 'mana');

INSERT INTO Collectible
VALUES
('Bracelet', 'Mission reward'), 
('Crown', 'Mission reward'),
('Ancient Coin', 'Hidden treasure'), 
('Golden Feather', 'Rare bird drop'), 
('Dragon Scale', 'Defeated a dragon');

INSERT INTO Owns
VALUES
(1, 'Bracelet'), 
(1, 'Crown'), 
(2, 'Bracelet'), 
(3, 'Bracelet'), 
(5, 'Bracelet'), 
(7, 'Bracelet'), 
(8, 'Bracelet'), 
(4, 'Ancient Coin'), 
(6, 'Dragon Scale');

INSERT INTO CharacterStats
VALUES
(1, 5, 3, 'fighter'), 
(2, 6, 4, 'fighter'), 
(3, 8, 4, 'fighter'),
(1, 3, 5, 'tank'), 
(2, 4, 6, 'tank'), 
(3, 4, 8, 'tank'),
(1, 7, 1, 'assassin'),
(2, 8, 2, 'assassin'),
(3, 9, 3, 'assassin');


INSERT INTO CreatesCharacter
VALUES
('Bob', 3, 'fighter', 1), 
('Joe', 3, 'tank', 2), 
('Alice', 2, 'mage', 3), 
('Eve', 5, 'rogue', 4), 
('Max', 1, 'archer', 5), 
('Luna', 4, 'healer', 6), 
('Kai', 6, 'summoner', 7), 
('Zane', 2, 'berserker', 8),
('Cody', 2, 'berserker', 9);

INSERT INTO ArmourName
VALUES
('Light headgear', 'common', 'helmet', 'defence'),
('Nice helmet', 'rare', 'helmet', 'defence'),
('Breastplate', 'rare', 'upper', 'attack'),
('Fleet footwear', 'rare', 'boots', 'attack'),
('Cool Shoes', 'epic', 'boots', 'attack');


INSERT INTO CraftsArmour
VALUES
(1, 'Light headgear', 'defence', 1), 
(2, 'Nice helmet', 'defence', 1), 
(3, 'Breastplate', 'attack', 1),
(4, 'Breastplate', 'defence', 2), 
(5, 'Fleet footwear', 'attack', 5);


INSERT INTO Equips
VALUES
(2, 'Bob'), 
(3, 'Bob'), 
(4, 'Joe'), 
(5, 'Joe'), 
(1, 'Joe');
