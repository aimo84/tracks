#!/usr/bin/python
import MySQLdb

db = MySQLdb.connect(host="localhost",    # your host, usually localhost
                     user="root",         # your username
                     passwd="",  # your password
                     db="gitlab")        # name of the data base
cur = db.cursor();
cur.execute("SELECT * FROM users")
with open('output2.txt') as f:
    content = f.readlines()
for con in content:
    con = con.replace('\n','')
    con = con.replace(',','')
    prop = con.split(' ')
    prop[2] = int(prop[2])
    prop[3] = int(prop[3])
    prop[4] = int(prop[4])
    prop[5] = int(prop[5])
    prop[6] = int(prop[6])
    print prop[0],prop[1],prop[2],prop[3],prop[4],prop[5],prop[6]
    try:
        query = """INSERT INTO users VALUES('%s','%s','%d','%d','%d','%d','%d')""" % (prop[0],prop[1],prop[2],prop[3],prop[4],prop[5],prop[6])
        print query
        cur.execute(query);
        db.commit()
        print 'insert successfull'
    except:
        db.rollback()
        print 'fail'
db.close();