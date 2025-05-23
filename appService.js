const oracledb = require('oracledb');
const loadEnvFile = require('./utils/envUtil');
const fs = require('fs');
const envVariables = loadEnvFile('./.env');

// Database configuration setup. Ensure your .env file has the required database credentials.
const dbConfig = {
    user: envVariables.ORACLE_USER,
    password: envVariables.ORACLE_PASS,
    connectString: `${envVariables.ORACLE_HOST}:${envVariables.ORACLE_PORT}/${envVariables.ORACLE_DBNAME}`,
    poolMin: 1,
    poolMax: 3,
    poolIncrement: 1,
    poolTimeout: 60
};

// initialize connection pool
async function initializeConnectionPool() {
    try {
        await oracledb.createPool(dbConfig);
        console.log('Connection pool started');
    } catch (err) {
        console.error('Initialization error: ' + err.message);
    }
}

async function closePoolAndExit() {
    console.log('\nTerminating');
    try {
        await oracledb.getPool().close(10); // 10 seconds grace period for connections to finish
        console.log('Pool closed');
        process.exit(0);
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
}

initializeConnectionPool();

process
    .once('SIGTERM', closePoolAndExit)
    .once('SIGINT', closePoolAndExit);


// ----------------------------------------------------------
// Wrapper to manage OracleDB actions, simplifying connection handling.
async function withOracleDB(action) {
    let connection;
    try {
        connection = await oracledb.getConnection(); // Gets a connection from the default pool 
        return await action(connection);
    } catch (err) {
        console.error(err);
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}


// ----------------------------------------------------------
// Core functions for database operations
// Modify these functions, especially the SQL queries, based on your project's requirements and design.
async function testOracleConnection() {
    return await withOracleDB(async (connection) => {
        return true;
    }).catch(() => {
        return false;
    });
}

async function fetchPlayertableFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM PLAYERJOINS');
        return result.rows;
    }).catch(() => {
        return [];
    });
}
async function fetchArmourtableFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM ARMOURNAME');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function initializeDB() {
    return await withOracleDB(async (connection) => {
        const initsql = fs.readFileSync('initschema.sql', 'utf8'); 
        const statements = initsql.split(/;\s*$/m); 
        for (let stmt of statements) {
            if (stmt.trim()) {
                await connection.execute(stmt); 
            }
        }
        return true;
    }).catch ((err) => {
        console.log(stmt, err)
        return false;
    });
}

async function insertPlayertable(username, email) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            'INSERT INTO PlayerJoins VALUES (player_seq.NEXTVAL, :username, :email, SYSDATE, NULL, NULL)',
            [username, email],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

async function countPlayertable() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT Count(*) FROM PlayerJoins');
        return result.rows[0][0];
    }).catch(() => {
        return -1;
    });
}

async function updateUserGuild(username, guildName, guildRole) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            'UPDATE PlayerJoins SET guildName = :guildName, role = :guildRole WHERE username = :username',
             [guildName, guildRole, username],
             { autoCommit: true }
        );

        if (result.rowsAffected === 0) {
            throw new Error(`User ${username} not found in PlayerJoins or Guild ${guildName} not found`);
        }

        await connection.execute(
            'UPDATE Guild SET memberCount = (SELECT COUNT(*) FROM PlayerJoins P WHERE p.guildName = :guildName)' ,
            [guildName],
            { autoCommit: true }
        )

        return result.rowsAffected && result.rowsAffected > 0;

    }).catch ((err) => {
        console.log(err)
        return false;
    })
}

async function deletePlayer(username) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            'DELETE FROM PlayerJoins WHERE username = :username',
            [username],
            { autoCommit: true }
        );

        return result.rowsAffected > 0; // Returns true only if a row was deleted
    }).catch((err) => {
        console.log(err);
        return false;
    });
}


async function selectPlayerTuples(query) {
    return await withOracleDB(async (connection) => {
        const statement = `SELECT * FROM PlayerJoins WHERE ${query}`
        console.log(statement)
        const result = await connection.execute(
            statement,
        )
        console.log(result);
        return result.rows;
        }).catch(() => {
            return [];
        });
}

async function selectArmourTuples(query) {
    return await withOracleDB(async (connection) => {
        const statement = `SELECT ${query} FROM ArmourName`
        const result = await connection.execute(
            statement,
        )
        return result.rows;
    }).catch(() => {
            return [];
    });
}

async function getMostPopularItems() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT name AS itemName, COUNT(*) AS ownershipCount
             FROM Owns
             GROUP BY name
             ORDER BY ownershipCount DESC`,
        );
        // const columnNames = result.metaData.map(col => col.name); 
        return result.rows;
    }).catch((err) => {
        console.error("Error fetching most popular items:", err);
        return [];
    });
}
async function getGuildsWithMoreThanTwoMembers() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT guildName, COUNT(*) AS memberCount
             FROM PlayerJoins
             WHERE guildName IS NOT NULL
             GROUP BY guildName
             HAVING COUNT(*) > 1
             ORDER BY memberCount DESC`
        );
        return result.rows; // Return the rows containing guild names and member counts
    }).catch((err) => {
        console.error("Error fetching guilds with more than two members:", err);
        return [];
    });
}

async function getGuildsWithAboveAverageFriendship() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `WITH OverallAverage AS (
                 SELECT AVG(B2.friendshipLevel) AS overallAvgFriendship
                 FROM Befriends B2
             )
             SELECT P.guildName, 
                    AVG(B.friendshipLevel) AS avgFriendshipLevel,
                    AVG(B.friendshipLevel) - (SELECT overallAvgFriendship FROM OverallAverage) AS differenceFromAverage
             FROM PlayerJoins P
             JOIN Befriends B ON P.accountID = B.account1ID
             GROUP BY P.guildName
             HAVING AVG(B.friendshipLevel) > (SELECT overallAvgFriendship FROM OverallAverage)`
        );
        return result.rows; // Return the rows containing guild names, their average friendship levels, and the difference
    }).catch((err) => {
        console.error("Error fetching guilds with friendship level differences:", err);
        return [];
    });
}
async function getUserArmour(username) {
    return await withOracleDB(async( connection) => {
        const result = await connection.execute(
            `SELECT armourID, boostType, name
             FROM PlayerJoins PJ
             INNER JOIN CraftsArmour CA
             ON PJ.accountID = CA.accountID
             WHERE PJ.username = :username`,
             [username],
             {autoCommit: true}
        )
        return result.rows;
    }).catch((err) => {
        console.error("Error finding username:", err);
        return [];
    });
}

async function getPlayersMissionsCompletedDivision(missions) {
    return await withOracleDB(async (connection) => {
        console.log(missions)
        const viewName = "GivenMissions";
        let view = `CREATE VIEW ${viewName}(missionID) AS
                    SELECT missionID
                    FROM Mission
                    WHERE `;

        if (!missions || missions.length === 0) {
            view += "1=0"; // No missions to include
        } else {
            const conditions = missions.map((missionID) => `missionID = ${missionID}`);
            view += conditions.join(" OR ");
        }

        console.log(view)
        console.log(view.rows)

        // Execute the view creation
        await connection.execute(view);

        // Perform the main query
        const result = await connection.execute(
            `SELECT accountID, username FROM PlayerJoins PJ
             WHERE NOT EXISTS (
                (SELECT missionID 
                 FROM ${viewName})
                MINUS
                (SELECT DISTINCT missionID
                 FROM Completes C
                 WHERE PJ.accountID = C.accountID)
             )`
        );
        console.log(result)
        await connection.execute(`DROP VIEW ${viewName}`);
        return result.rows;
    }).catch((err) => {
        console.error("Error finding players that have completed all of the given missions:", err);
        return [];
    });
}

module.exports = {
    testOracleConnection,
    insertPlayertable,
    fetchPlayertableFromDb,
    fetchArmourtableFromDb,
    countPlayertable,
    initializeDB,
    deletePlayer,
    updateUserGuild,
    selectPlayerTuples,
    getMostPopularItems,
    selectArmourTuples,
    getUserArmour,
    getGuildsWithMoreThanTwoMembers,
    getGuildsWithAboveAverageFriendship,
    getPlayersMissionsCompletedDivision
};