DROP TABLE ARMOURNAME CASCADE CONSTRAINTS;
DROP TABLE ARMOURSTAT CASCADE CONSTRAINTS;
DROP TABLE BEFRIENDS CASCADE CONSTRAINTS;
DROP TABLE CHARACTERSTATS CASCADE CONSTRAINTS;
DROP TABLE CHALLENGES CASCADE CONSTRAINTS;
DROP TABLE COLLECTIBLE CASCADE CONSTRAINTS;
DROP TABLE COMPLETES CASCADE CONSTRAINTS;
DROP TABLE CONSUMABLE CASCADE CONSTRAINTS;
DROP TABLE CONSUMABLESTAT CASCADE CONSTRAINTS;
DROP TABLE CRAFTSARMOUR CASCADE CONSTRAINTS;
DROP TABLE CREATESCHARACTER CASCADE CONSTRAINTS;
DROP TABLE EQUIPS CASCADE CONSTRAINTS;
DROP TABLE GUILD CASCADE CONSTRAINTS;
DROP TABLE HAVESTAGE CASCADE CONSTRAINTS;
DROP TABLE ITEM CASCADE CONSTRAINTS;
DROP TABLE LEARNSSKILL CASCADE CONSTRAINTS;
DROP TABLE MISSION CASCADE CONSTRAINTS;
DROP TABLE OWNS CASCADE CONSTRAINTS;
DROP TABLE PLAYERJOINS CASCADE CONSTRAINTS;
DROP TABLE QUESTINFO CASCADE CONSTRAINTS;
DROP TABLE QUESTLOCATION CASCADE CONSTRAINTS;
DROP SEQUENCE player_seq;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE TABLE Guild (
    name VARCHAR(16) PRIMARY KEY, 
    memberCount INTEGER NOT NULL, 
    description VARCHAR(255) 
);

CREATE TABLE PlayerJoins ( 
    accountID INTEGER PRIMARY KEY,
    username VARCHAR(16) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL, 
    createDate DATE, 
    role VARCHAR(255), 
    guildName VARCHAR(16), 
    FOREIGN KEY (guildName) REFERENCES Guild(name) 
);

CREATE TABLE Befriends (
    account1ID INTEGER,
    account2ID INTEGER,
    friendshipLevel INTEGER NOT NULL,
    PRIMARY KEY (account1ID, account2ID),
    FOREIGN KEY (account1ID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE, 
    FOREIGN KEY (account2ID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE
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
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE, 
    FOREIGN KEY (missionID) REFERENCES Mission(missionID) 
);

CREATE TABLE Item (
    name VARCHAR(30) PRIMARY KEY, 
    description VARCHAR(64)
);

CREATE TABLE ConsumableStat ( 
    rarity VARCHAR(16), 
    stat INTEGER NOT NULL, 
    boostType VARCHAR(8), 
    PRIMARY KEY (rarity, boostType) 
);

CREATE TABLE Consumable ( 
    name VARCHAR(16), 
    count INTEGER NOT NULL, 
    rarity VARCHAR(16) NOT NULL, 
    boostType VARCHAR(8) NOT NULL, 
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
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE, 
    FOREIGN KEY (name) REFERENCES Item(name) 
);

CREATE TABLE CharacterStats ( 
    characterLevel INTEGER, 
    attack INTEGER NOT NULL, 
    defence INTEGER NOT NULL, 
    class VARCHAR(8), 
    PRIMARY KEY (characterLevel, class) 
);

CREATE TABLE CreatesCharacter ( 
    name VARCHAR(16) PRIMARY KEY, 
    characterLevel INTEGER NOT NULL, 
    class VARCHAR(10) NOT NULL,
    playerID INTEGER UNIQUE NOT NULL, 
    FOREIGN KEY (playerID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE
);

CREATE TABLE ArmourName (
    name VARCHAR(16) PRIMARY KEY,
    rarity VARCHAR(16) NOT NULL, 
    equipType VARCHAR(8) NOT NULL, 
    boostType VARCHAR(8) NOT NULL
);


CREATE TABLE ArmourStat ( 
    rarity VARCHAR(16), 
    stat INTEGER NOT NULL, 
    boostType VARCHAR(8), 
    equipType VARCHAR(8), 
    PRIMARY KEY (rarity, boostType, equipType) 
);

CREATE TABLE CraftsArmour (
    armourID INTEGER PRIMARY KEY, 
    name VARCHAR(16) NOT NULL, 
    boostType VARCHAR(8) NOT NULL,
    accountID INTEGER NOT NULL, 
    FOREIGN KEY (accountID) REFERENCES PlayerJoins(accountID) ON DELETE CASCADE
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
    stageID INTEGER, 
    objective VARCHAR(255), 
    questID INTEGER, 
    PRIMARY KEY (stageID, questID),
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

INSERT INTO Guild VALUES ('Goats Guild', 3, 'A guild for goats all around the world'); 
INSERT INTO Guild VALUES ('Best Players', 2, 'Only the best players are in this guild'); 
INSERT INTO Guild VALUES ('Guild 1', 1, 'guild 1 description'); 
INSERT INTO Guild VALUES ('Guild 2', 1, 'guild 2 description'); 
INSERT INTO Guild VALUES ('Guild 3', 1, 'guild 3 description');

INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'playerone', 'iplaygames@email.com', '2025-01-01', 'member', 'Best Players'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'thegoat', 'goatedgamer@email.com', '2025-01-05', 'leader', 'Goats Guild'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'legoat', 'goatedgamer@email.com', '2025-02-05', 'deputy', 'Goats Guild'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'dabest', 'bestest@email.com', '2025-02-20', 'leader', 'Best Players'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'mountaingoat', 'mountaingoat@email.com', '2025-02-21', 'member', 'Goats Guild'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'solo', 'soloplayer@email.com', '2025-02-22', NULL, NULL); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'lesunshine', 'a@gmail.com', '2025-02-22', 'leader', 'Guild 1'); 
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'lebron', 'b@gmail.com', '2025-02-22', 'leader', 'Guild 2');
INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, 'leGM', 'c@gmail.com', '2025-02-22', 'leader', 'Guild 3');

INSERT INTO Befriends VALUES (1, 2, 10); 
INSERT INTO Befriends VALUES (2, 3, 23); 
INSERT INTO Befriends VALUES (2, 5, 5); 
INSERT INTO Befriends VALUES (3, 5, 1); 
INSERT INTO Befriends VALUES (7, 8, 5);

INSERT INTO Mission VALUES (101, 'kill 3 monsters', '10 coins'); 
INSERT INTO Mission VALUES (102, 'defeat a boss character', 'crown'); 
INSERT INTO Mission VALUES (103, 'add a friend', 'friendship bracelet'); 
INSERT INTO Mission VALUES (104, 'finish first quest', '10 coins');
INSERT INTO Mission VALUES (105, 'finish all quests', '100000 coins');

INSERT INTO Completes VALUES (1, 101, '2025-01-01'); 
INSERT INTO Completes VALUES (1, 102, '2025-01-01'); 
INSERT INTO Completes VALUES (1, 103, '2025-01-05'); 
INSERT INTO Completes VALUES (2, 104, '2025-01-05'); 
INSERT INTO Completes VALUES (3, 104, '2025-02-05');

INSERT INTO Item VALUES ('Bracelet', 'A token of your friendship'); 
INSERT INTO Item VALUES ('Crown', 'Reward for defeating your first boss'); 
INSERT INTO Item VALUES ('Ancient Coin', 'A rare coin from ancient times');
INSERT INTO Item VALUES ('Golden Feather', 'A shimmering feather from a rare bird');
INSERT INTO Item VALUES ('Dragon Scale', 'A tough scale from a defeated dragon');
INSERT INTO Item VALUES ('Sandwich', 'A tasty sandwich that boosts attack');
INSERT INTO Item VALUES ('Strength potion', 'A potion that increases your strength temporarily');
INSERT INTO Item VALUES ('Healing Herb', 'A magical herb that restores health');
INSERT INTO Item VALUES ('Energy Drink', 'A beverage that restores stamina');
INSERT INTO Item VALUES ('Elixir of Wisdom', 'A rare potion that increases mana');

INSERT INTO ConsumableStat VALUES ('common', 2, 'attack'); 
INSERT INTO ConsumableStat VALUES ('common', 4, 'defence'); 
INSERT INTO ConsumableStat VALUES ('common', 5, 'stamina'); 
INSERT INTO ConsumableStat VALUES ('common', 5, 'health'); 
INSERT INTO ConsumableStat VALUES ('rare', 5, 'attack'); 
INSERT INTO ConsumableStat VALUES ('rare', 8, 'defence'); 
INSERT INTO ConsumableStat VALUES ('rare', 10, 'stamina'); 
INSERT INTO ConsumableStat VALUES ('rare', 10, 'health'); 
INSERT INTO ConsumableStat VALUES ('rare', 10, 'mana'); 
INSERT INTO ConsumableStat VALUES ('legendary', 10, 'attack');
INSERT INTO ConsumableStat VALUES ('legendary', 16, 'defence');
INSERT INTO ConsumableStat VALUES ('legendary', 20, 'mana');

INSERT INTO Consumable VALUES ('Sandwich', 5, 'common', 'attack'); 
INSERT INTO Consumable VALUES ('Strength potion', 2, 'rare', 'attack'); 
INSERT INTO Consumable VALUES ('Healing Herb', 3, 'rare', 'health'); 
INSERT INTO Consumable VALUES ('Energy Drink', 4, 'common', 'stamina'); 
INSERT INTO Consumable VALUES ('Elixir of Wisdom', 1, 'legendary', 'mana');


INSERT INTO Collectible VALUES ('Bracelet', 'Mission reward'); 
INSERT INTO Collectible VALUES ('Crown', 'Mission reward');
INSERT INTO Collectible VALUES ('Ancient Coin', 'Hidden treasure'); 
INSERT INTO Collectible VALUES ('Golden Feather', 'Rare bird drop'); 
INSERT INTO Collectible VALUES ('Dragon Scale', 'Defeated a dragon');

INSERT INTO Owns VALUES (1, 'Bracelet'); 
INSERT INTO Owns VALUES (1, 'Crown'); 
INSERT INTO Owns VALUES (2, 'Bracelet'); 
INSERT INTO Owns VALUES (3, 'Bracelet'); 
INSERT INTO Owns VALUES (5, 'Bracelet'); 
INSERT INTO Owns VALUES (7, 'Bracelet'); 
INSERT INTO Owns VALUES (8, 'Bracelet'); 
INSERT INTO Owns VALUES (4, 'Ancient Coin'); 
INSERT INTO Owns VALUES (6, 'Dragon Scale');

INSERT INTO CharacterStats VALUES (1, 5, 3, 'fighter'); 
INSERT INTO CharacterStats VALUES (2, 6, 4, 'fighter'); 
INSERT INTO CharacterStats VALUES (3, 8, 4, 'fighter');
INSERT INTO CharacterStats VALUES (1, 3, 5, 'tank'); 
INSERT INTO CharacterStats VALUES (2, 4, 6, 'tank'); 
INSERT INTO CharacterStats VALUES (3, 4, 8, 'tank');
INSERT INTO CharacterStats VALUES (1, 7, 1, 'mage');
INSERT INTO CharacterStats VALUES (2, 8, 2, 'mage');
INSERT INTO CharacterStats VALUES (3, 9, 3, 'mage');

INSERT INTO CreatesCharacter VALUES ('Bob', 3, 'fighter', 1); 
INSERT INTO CreatesCharacter VALUES ('Joe', 3, 'tank', 2); 
INSERT INTO CreatesCharacter VALUES ('Alice', 2, 'mage', 3); 
INSERT INTO CreatesCharacter VALUES ('Eve', 2, 'fighter', 4); 
INSERT INTO CreatesCharacter VALUES ('Max', 1, 'mage', 5); 
INSERT INTO CreatesCharacter VALUES ('Luna', 2, 'tank', 6); 
INSERT INTO CreatesCharacter VALUES ('Kai', 3, 'mage', 7); 
INSERT INTO CreatesCharacter VALUES ('Zane', 1, 'fighter', 8);
INSERT INTO CreatesCharacter VALUES ('Cody', 1, 'tank', 9);

INSERT INTO ArmourName VALUES ('Light headgear', 'common', 'helmet', 'defence');
INSERT INTO ArmourName VALUES ('Nice helmet', 'rare', 'helmet', 'defence');
INSERT INTO ArmourName VALUES ('Breastplate', 'rare', 'upper', 'attack');
INSERT INTO ArmourName VALUES ('Fleet footwear', 'rare', 'boots', 'attack');
INSERT INTO ArmourName VALUES ('Cool Shoes', 'epic', 'boots', 'attack');

INSERT INTO CraftsArmour VALUES (1, 'Light headgear', 'defence', 1); 
INSERT INTO CraftsArmour VALUES (2, 'Nice helmet', 'defence', 1); 
INSERT INTO CraftsArmour VALUES (3, 'Breastplate', 'attack', 1);
INSERT INTO CraftsArmour VALUES (4, 'Breastplate', 'defence', 2); 
INSERT INTO CraftsArmour VALUES (5, 'Fleet footwear', 'attack', 5);

INSERT INTO ArmourStat VALUES ('rare', 5, 'attack', 'upper'); 
INSERT INTO ArmourStat VALUES ('rare', 6, 'defence', 'upper');
INSERT INTO ArmourStat VALUES ('common', 2, 'defence', 'helmet'); 
INSERT INTO ArmourStat VALUES ('common', 1, 'attack', 'helmet'); 
INSERT INTO ArmourStat VALUES ('rare', 4, 'defence', 'helmet');
INSERT INTO ArmourStat VALUES ('rare', 3, 'attack', 'boots');

INSERT INTO Equips VALUES (2, 'Bob'); 
INSERT INTO Equips VALUES (3, 'Bob'); 
INSERT INTO Equips VALUES (4, 'Joe'); 
INSERT INTO Equips VALUES (5, 'Joe'); 
INSERT INTO Equips VALUES (1, 'Joe');

INSERT INTO LearnsSkill VALUES ('Bob Punch', 'Deals damage to enemy based on attack', 'Bob'); 
INSERT INTO LearnsSkill VALUES ('Bob Block', 'Decreases incoming damage by defence stat', 'Bob'); 
INSERT INTO LearnsSkill VALUES ('Joe Protect', 'Decreases incoming damage by 2x defence stat', 'Joe'); 
INSERT INTO LearnsSkill VALUES ('Alice Cast', 'Grants a 1.5x buff for magical attacks', 'Alice'); 
INSERT INTO LearnsSkill VALUES ('Alice Dodge', '50% chance of taking no damage', 'Alice');

INSERT INTO QuestLocation VALUES ('Dungeon', 'Skeleton King'); 
INSERT INTO QuestLocation VALUES ('Forest', 'Ferocious Bear'); 
INSERT INTO QuestLocation VALUES ('Desert', 'Prickly Cactus'); 
INSERT INTO QuestLocation VALUES ('Enchanted Lake', 'Aquatic Monstrosity');
INSERT INTO QuestLocation VALUES ('Castle', 'Arrogant Tyrant');

INSERT INTO QuestInfo VALUES (1, 'Skeleton King'); 
INSERT INTO QuestInfo VALUES (2, 'Ferocious Bear'); 
INSERT INTO QuestInfo VALUES (3, 'Prickly Cactus'); 
INSERT INTO QuestInfo VALUES (4, 'Aquatic Monstrosity'); 
INSERT INTO QuestInfo VALUES (5, 'Arrogant Tyrant');

INSERT INTO HaveStage VALUES (1, 'defeat 3 enemies', 1); 
INSERT INTO HaveStage VALUES (2, 'find treasure chest', 1); 
INSERT INTO HaveStage VALUES (3, 'defeat all enemies', 1); 
INSERT INTO HaveStage VALUES (1, 'find hidden path', 2); 
INSERT INTO HaveStage VALUES (2, 'defeat all enemies', 2);
INSERT INTO HaveStage VALUES (1, 'find hidden path', 3); 
INSERT INTO HaveStage VALUES (2, 'defeat all enemies', 3); 
INSERT INTO HaveStage VALUES (1, 'collect 5 herbs', 4); 
INSERT INTO HaveStage VALUES (1, 'reach location without being seen', 5); 
INSERT INTO HaveStage VALUES (2, 'defeat all enemies', 5);

INSERT INTO Challenges VALUES ('Bob', 1, '2025-01-01'); 
INSERT INTO Challenges VALUES ('Bob', 2, '2025-01-01'); 
INSERT INTO Challenges VALUES ('Joe', 1, '2025-01-05'); 
INSERT INTO Challenges VALUES ('Joe', 2, '2025-01-05'); 
INSERT INTO Challenges VALUES ('Joe', 3, '2025-01-06');

COMMIT;