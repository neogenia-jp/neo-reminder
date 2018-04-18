DROP TABLE reminder_element
;

CREATE TABLE reminder_element (
	id INTEGER PRIMARY KEY,
    title TEXT ,
    notify_datetime TEXT ,
    term TEXT ,
    memo TEXT ,
    finished_at TEXT ,
    created_at TEXT 
)
;
