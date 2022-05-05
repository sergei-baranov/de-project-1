-- create dm_rfm_segments table
CREATE TABLE analysis.dm_rfm_segments (
    user_id integer PRIMARY KEY,
    recency smallint NOT NULL,
    frequency smallint NOT NULL,
    monetary_value smallint NOT NULL,
    CHECK (recency BETWEEN 1 AND 5),
    CHECK (frequency BETWEEN 1 AND 5),
    CHECK (monetary_value BETWEEN 1 AND 5)
);