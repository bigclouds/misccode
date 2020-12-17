helloflask.db

```
# @ bash
sqlite3 helloflask.db

# @ sqlite shell
create table cncounter(cn text primary key, counter smallint);
insert into cncounter values('client', 0);
.quit
```
