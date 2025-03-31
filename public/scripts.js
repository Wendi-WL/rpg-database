/*
 * These functions below are for various webpage functionalities. 
 * Each function serves to process data on the frontend:
 *      - Before sending requests to the backend.
 *      - After receiving responses from the backend.
 * 
 * To tailor them to your specific needs,
 * adjust or expand these functions to match both your 
 *   backend endpoints 
 * and 
 *   HTML structure.
 * 
 */


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
    const demotableContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    demotableContent.forEach(player=> {
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




// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchTableData();
    document.getElementById("resetDemotable").addEventListener("click", resetDemotable);
    document.getElementById("insertPlayertable").addEventListener("submit", insertPlayertable);
    document.getElementById("updateUserGuild").addEventListener("submit", updateUserGuild);
    document.getElementById("countPlayertable").addEventListener("click", countPlayertable);
};

// General function to refresh the displayed table data. 
// You can invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayPlayers();
}
