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
    if (deletePlayerResult) {
        res.json({success: true});
    } else {
        res.status(500).json({success: false})
    }
})

router.get('/select-player-tuples/:query', async(req, res) => {
    query = req.params.query;
    const selectPlayerTuples = await appService.selectPlayerTuples(query);
    res.json({data: selectPlayerTuples});
})

router.get('/project-armour-attributes/:query', async(req, res) => {
    query = req.params.query;
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




module.exports = router;