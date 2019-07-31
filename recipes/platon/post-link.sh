
DB_PATH=https://zenodo.org/record/3349652/files/db.tar.gz

wget -q -nH $DB_PATH
if [ $? -ne 0 ]; then
	echo "failed to donwload Platon database ($DB_PATH)
	exit(1
fi

tar -xzf db.tar.gz
if [ $? -ne 0 ]; then
        echo "failed to extract Platon database ($PREFIX/db.tar.gz)
        exit(1
fi

rm db.tar.gz

echo "Downloaded database path: ${PREFIX}/db\n\nPlease, invoke Platon providing this database path:\n\nExample:\nplaton --db ${PREFIX}/db" > $PREFIX/.messages.txt
