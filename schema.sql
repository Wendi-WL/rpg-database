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