-- [UP]
CREATE TABLE notification_history (
	id INTEGER PRIMARY KEY,
    reminder_element_id TEXT ,
    nitification_title TEXT ,
    nitification_dt TEXT ,
    created_at TEXT 
)
;

-- [DOWN]
DROP TABLE notification_history
;
