# project_template
# Please include any additional information that will be useful to your TA in your README! Remember, your goal is to make it easy for your TA to give you points!

Our project will model a database from a generic RPG (Role-Playing game) video game.

## To deploy on server (mac)

Copy local file onto school computer.
`scp -r <location of the project folder> YOUR-CWL-ID@remote.students.cs.ubc.ca:<destination on the server>`

SSH onto school computer.

`ssh YOUR-CWL-ID@remote.students.cs.ubc.ca`

Start remote server.

`sh ./remote-start.sh`

Which to local directory, run:

`sh ./scripts/mac/server-tunnel.sh`

## To deploy on server (windows)
