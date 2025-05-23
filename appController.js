const express = require('express');
const appService = require('./appService');

const router = express.Router();

// ----------------------------------------------------------
// API endpoints
// Modify or extend these routes based on your project's needs.
router.get('/check-db-connection', async (req, res) => {
    const isConnect = await appService.testOracleConnection();
    if (isConnect) {
        res.send('connected');
    } else {
        res.send('unable to connect');
    }
});

router.post('/initialize-db', async (req, res) => {
    const initDB = await appService.initializeDB();
    if (initDB) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.get('/playertable', async (req, res) => {
    const tableContent = await appService.fetchPlayertableFromDb();
    res.json({data: tableContent});
});

router.get('/armourtable', async (req, res) => {
    const tableContent = await appService.fetchArmourtableFromDb();
    res.json({data: tableContent});
});

router.post("/insert-playertable", async (req, res) => {
    const { username, email } = req.body;
    const insertResult = await appService.insertPlayertable(username, email);
    if (insertResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post('/update-user-guild', async (req, res) => {
    const { username, guildName, guildRole } = req.body;
    const updateResult = await appService.updateUserGuild(username, guildName, guildRole);
    if (updateResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});


router.delete('/delete-player', async(req, res) => {
    const {username} = req.body
    const deletePlayerResult = await appService.deletePlayer(username);
    console.log(deletePlayerResult)
    if (deletePlayerResult) {
        res.json({success: true});
    } else {
        res.status(500).json({success: false})
    }
})

router.get('/select-player-tuples/:query', async(req, res) => {
    query = req.params.query;
    const queryRegex = /^((accountID|username|createDate|role|guildName)\s(=|<|>)\s('[^']*'|\d+)\s*(AND|OR)\s*)*(accountID|username|createDate|role|guildName)\s(=|<|>)\s('[^']*'|\d+)\s*$/;

    // Validate the query against the regex
    if (!queryRegex.test(query)) {
        return res.status(400).json({ success: false, message: "Invalid query format" });
    }

    const selectPlayerTuples = await appService.selectPlayerTuples(query);
    res.json({data: selectPlayerTuples});
})

router.get('/project-armour-attributes/:query', async(req, res) => {
    query = req.params.query;
    // console.log(query)
    const queryRegex = /^(name|Rarity|EquipType|BoostType)(\s*,\s*(name|Rarity|EquipType|BoostType))*$/;

    // Validate the query against the regex
    if (!queryRegex.test(query)) {
        // console.log("ERRORORORO!!!")
        return res.status(400).json({ success: false, message: "Invalid query format" });
    }
    const armourAttributes = await appService.selectArmourTuples(query);
    res.json({data: armourAttributes});
})

router.get('/count-playertable', async (req, res) => {
    const tableCount = await appService.countPlayertable();
    if (tableCount >= 0) {
        res.json({ 
            success: true,  
            count: tableCount
        });
    } else {
        res.status(500).json({ 
            success: false, 
            count: tableCount
        });
    }
});

router.get('/most-popular-items', async (req, res) => {
    try {
        const popularItems = await appService.getMostPopularItems();
        res.json({ success: true, data: popularItems });
    } catch (err) {
        console.error("Error fetching most popular items:", err);
        res.status(500).json({ success: false, message: "Failed to fetch most popular items" });
    }
});

router.get('/guilds-with-two-members', async (req, res) => {
    try {
        const data = await appService.getGuildsWithMoreThanTwoMembers();
        res.json({ success: true, data: data});
    } catch(err) {
        console.error("Error fetching guilds with two or more members", err);
        res.status(500).json({ success: false, message: "Failed to fetch guilds" });
    }
})

router.get('/guilds-with-good-friendship', async (req, res) => {
    try {
        const data = await appService.getGuildsWithAboveAverageFriendship();
        res.json({ success: true, data: data});
    } catch(err) {
        console.error("Error fetching guilds with above average friendship", err);
        res.status(500).json({ success: false, message: "Failed to fetch guilds" });
    }
})

router.get('/find-user-armour/:query', async(req, res) => {
    const username = req.params.query;
    try {
        const armour = await appService.getUserArmour(username);
        console.log("success")
        res.json({success: true, data: armour});


    } catch (err) {
        console.error("Error finding username: ", err);
        res.status(500).json({ success: false, message: "Failed to find username" });
    }
})

router.post('/players-missions-completed-division', async (req, res) => {
    try {
        const { missions } = req.body;  // Retrieve missions array from the request body
        if (!Array.isArray(missions)) {
            return res.status(400).json({ success: false, message: "Missions must be an array" });
        }

        const playersCompletingAllMissions = await appService.getPlayersMissionsCompletedDivision(missions);
        res.json({ success: true, data: playersCompletingAllMissions });
    } catch (err) {
        console.error("Error fetching players completing all given missions:", err);
        res.status(500).json({ success: false, message: "Failed to fetch players completing all given missions" });
    }
});

module.exports = router;