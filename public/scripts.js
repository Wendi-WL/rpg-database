// Helper Function to generate tables dynamically
function generateTable(divId, data, cols) {
    const container = document.getElementById(divId);
    if (!container) {
        console.error(`Element with ID "${divId}" not found.`);
        return;
    }

    if (!Array.isArray(data) || data.length === 0) {
        container.innerHTML = "<p>No data available</p>";
        return;
    }

    // Extract column names dynamically from the first object
    const columns = cols;

    // Generate table header
    let theadHTML = "<thead><tr>";
    columns.forEach(col => {
        if (col){
            col = col.charAt(0).toUpperCase() + col.slice(1).toLowerCase();
        }
        theadHTML += `<th>${col}</th>`;
    });
    theadHTML += "</tr></thead>";

    // Generate table body
    let tbodyHTML = "<tbody>";
    data.forEach(row => {
        tbodyHTML += "<tr>";
        columns.forEach((col, i) => {
            let elem = (i < row.length)? row[i]: "N/A";
            tbodyHTML += `<td>${elem}</td>`;
        });
        tbodyHTML += "</tr>";
    });
    tbodyHTML += "</tbody>";

    // Insert table into the container
    container.innerHTML = `<table border="1">${theadHTML}${tbodyHTML}</table>`;
}

// This function checks the database connection and updates its status on the frontend.
async function checkDbConnection() {
    const statusElem = document.getElementById('dbStatus');
    const loadingGifElem = document.getElementById('loadingGif');

    const response = await fetch('/check-db-connection', {
        method: "GET"
    });

    // Hide the loading GIF once the response is received.
    loadingGifElem.style.display = 'none';
    // Display the statusElem's text in the placeholder.
    statusElem.style.display = 'inline';

    response.text()
    .then((text) => {
        statusElem.textContent = text;
    })
    .catch((error) => {
        statusElem.textContent = 'connection timed out';  // Adjust error handling if required.
    });
}

// Fetches data from the demotable and displays it.
async function fetchAndDisplayPlayers() {
    const tableElement = document.getElementById('playertable');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/playertable', {
        method: 'GET'
    });

    const responseData = await response.json();
    console.log(responseData)
    const playerContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    playerContent.forEach(player=> {
        const row = tableBody.insertRow();
        player.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

async function fetchAndDisplayArmour() {
    const tableElement = document.getElementById('armourtable');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/armourtable', {
        method: 'GET'
    });

    const responseData = await response.json();
    console.log(responseData)
    const armourContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    armourContent.forEach(player=> {
        const row = tableBody.insertRow();
        player.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// This function resets or initializes the tables
async function resetDemotable() {
    const response = await fetch("/initialize-db", {
        method: 'POST'
    });
    const responseData = await response.json();
    fetchTableData()
    if (responseData.success){
        alert("Success")
    } else {
        alert("Error initializing table")
    }
}

// **** QUERIES START HERE ****

// Counts rows in the demotable.
// Modify the function accordingly if using different aggregate functions or procedures.
async function countPlayertable() {
    const response = await fetch("/count-playertable", {
        method: 'GET'
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('countResultMsg');

    if (responseData.success) {
        const tupleCount = responseData.count;
        messageElement.textContent = `The number of tuples in playertable: ${tupleCount}`;
    } else {
        alert("Error in count demotable!");
    }
}

// Inserts player tuple into PlayerJoins Table
async function insertPlayertable(event) {
    event.preventDefault();

    const usernameValue = document.getElementById('insertUsername').value;
    const emailValue = document.getElementById('insertEmail').value;

    const response = await fetch('/insert-playertable', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: usernameValue,
            email: emailValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('insertResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Data inserted successfully!";
        fetchTableData();
    } else {
        messageElement.textContent = "Error inserting data!";
    }
}


// Updates a user's guild and gives them a role
async function updateUserGuild(event) {
    event.preventDefault();
    const usernameValue = document.getElementById('updateGuild').value;
    const guildNameValue = document.getElementById('updateUserGuildName').value;
    const guildRoleValue = document.getElementById('updateUserGuildRole').value;
    try {
        const response = await fetch('/update-user-guild', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: usernameValue,
                guildName: guildNameValue,
                guildRole: guildRoleValue
            })
        });
        const responseData = await response.json();
        const messageElement = document.getElementById('updateUserGuildResultMsg');

        if (responseData.success) {
            messageElement.textContent = "Success";
            alert(`Added ${usernameValue} to ${guildNameValue}`)
            fetchTableData();
        } else {
            alert("Nonexistant username or guild");
        }
    } catch(error) {
        console.log(error)
    }
}

// deletes a player when given a username
async function deletePlayer(event) {
    event.preventDefault();
    const usernameValue = document.getElementById("deleteUsername").value
    const response = await fetch("/delete-player", {
        method: "DELETE",
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: usernameValue,

        })
    });
    const responseData = await response.json();
    const messageElement = document.getElementById('deletePlayerMsg');
    if (responseData.success) {
        messageElement.textContent = "Success";
        alert(`Deleted ${usernameValue}`)
        fetchTableData();
    } else {
        alert(`${username} not found`);
    }
}

function addFilter() {
    let filtersDiv = document.getElementById("filters");
    let filterGroup = document.createElement("div");
    filterGroup.classList.add("filter-group");

    let logicalOp = document.createElement("select");
    logicalOp.name = "logicalOp";
    logicalOp.innerHTML = '<option value="AND">AND</option><option value="OR">OR</option>';
    
    let attributeSelect = document.querySelector("select[name='attribute']").cloneNode(true);
    let operatorSelect = document.querySelector("select[name='operator']").cloneNode(true);
    let valueInput = document.createElement("input");
    valueInput.type = "text";
    valueInput.name = "value";
    valueInput.placeholder = "Enter value";
    
    filterGroup.appendChild(logicalOp);
    filterGroup.appendChild(attributeSelect);
    filterGroup.appendChild(operatorSelect);
    filterGroup.appendChild(valueInput);
    
    filtersDiv.appendChild(filterGroup);
}

// Selection of player tuples
async function selectPlayerTuples(event) {
    event.preventDefault()

    let filters = [];
    let filterGroups = document.querySelectorAll(".filter-group");
    console.log(filterGroups)
    filterGroups.forEach((group, index) => {
        let logicalOp = group.querySelector("select[name='logicalOp']")?.value || (index > 0 ? "AND" : ""); 
        let attribute = group.querySelector("select[name='attribute']").value;
        let operator = group.querySelector("select[name='operator']").value;
        let value = group.querySelector("input[name='value']").value;

        filters.push({ logicalOp, attribute, operator, value });
    });

    let query = ""
    for(let i = 0; i < filters.length; i++){
        if (i === 0){
            query = `${filters[i].attribute} ${filters[i].operator} '${filters[i].value}'`
        } else {
            query = `${query} ${filters[i].logicalOp} ${filters[i].attribute} ${filters[i].operator} '${filters[i].value}'`
        }
    }
    console.log("Query is " + query)
    
    const response = await fetch(`/select-player-tuples/${query}`, {
        method: 'GET',
    });

    const tableElement = document.getElementById('selecttable');
    // const tableBody = tableElement.querySelector('tbody');

    const responseData = await response.json();

    const tuples = responseData.data;

    generateTable('selecttable', tuples, ['Account ID', 'Username', 'Email', 'Date created:', 'Role', 'Guild Name'])
}

// Function to get most popular items from Owns table
async function selectMostPopularItems() {
    const res = await fetch(`/most-popular-items`, { method: 'GET' });
    const jsonData = await res.json(); 
    console.log("rows", jsonData.data.rows)
    generateTable('popularitemstable', jsonData.data, ['item', 'Number of Owners'])
}

// Function to get guilds with > 2 members
async function selectGuildsWithMembers() {
    const res = await fetch(`/guilds-with-two-members`, { method: 'GET' });
    const jsonData = await res.json(); 
    console.log("rows", jsonData.data.rows)
    generateTable('guildtwotable', jsonData.data, ['Guild Name', 'Total Members'])
}

// Function to get guilds with above average friendship level
async function selectGuildsWithAboveAverageFriendship() {
    const res = await fetch(`/guilds-with-good-friendship`, { method: 'GET' });
    const jsonData = await res.json(); 
    console.log("rows", jsonData.data.rows)
    generateTable('guildfriendshiptable', jsonData.data, ['Guild Name', 'Friendship Level', 'Difference From Mean'])
}
// Function to project the armour attributes
async function projectArmourAttributes(event) {
    event.preventDefault();
    const form = document.getElementById("armourForm");
    const checkboxes = form.querySelectorAll("input[type='checkbox']:checked");

    const selectedColumns = Array.from(checkboxes).map(cb => cb.value);
    const values = selectedColumns.join(", ")

    const response = await fetch(`/project-armour-attributes/${values}`, {
        method: "GET"
    })

    const responseData = await response.json();

    const tableElement = document.getElementById('armourtable');
    const tableHead = tableElement.querySelector('thead');
    const tableBody = tableElement.querySelector('tbody');

    tableHead.innerHTML = '';
    tableBody.innerHTML = '';

    const headerRow = tableHead.insertRow();
    selectedColumns.forEach(column => {
        const th = document.createElement("th");
        th.textContent = column;
        headerRow.appendChild(th);
    });
    const tuples = responseData.data;

    tuples.forEach(armour => {
        const row = tableBody.insertRow();
        armour.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// function that joins playerjoins and craftsamour to find a user's armour
async function findUserArmour(event){
    event.preventDefault();
    const tableElement = document.getElementById('userArmourTable');
    const tableBody = tableElement.querySelector('tbody');

    const usernameValue = document.getElementById("findArmour").value
    const response = await fetch(`/find-user-armour/${usernameValue}`, {
        method: "GET",
    });

    const responseData = await response.json();
    console.log(responseData)
    const armourContent = responseData.data;

    if (tableBody) {
        tableBody.innerHTML = '';
    }

    armourContent.forEach(player=> {
        const row = tableBody.insertRow();
        player.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchTableData();
    document.getElementById("resetDemotable").addEventListener("click", resetDemotable);
    document.getElementById("insertPlayertable").addEventListener("submit", insertPlayertable);
    document.getElementById("updateUserGuild").addEventListener("submit", updateUserGuild);
    document.getElementById("deletePlayer").addEventListener("submit", deletePlayer);
    document.getElementById("countPlayertable").addEventListener("click", countPlayertable);
    document.getElementById("addFilterBtn").addEventListener("click", addFilter);
    document.getElementById("selectForm").addEventListener("submit", selectPlayerTuples);
    document.getElementById("popularItemsButton").addEventListener("click", selectMostPopularItems);
    
    document.getElementById("armourForm").addEventListener("submit", projectArmourAttributes);
    document.getElementById("guildswithtwoButton").addEventListener("click", selectGuildsWithMembers);
    document.getElementById("guildswithfriendshipButton").addEventListener('click', selectGuildsWithAboveAverageFriendship);
    document.getElementById("userArmour").addEventListener("submit", findUserArmour);
};

// General function to refresh the displayed table data. 
// You can invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayPlayers();
    fetchAndDisplayArmour();
}
