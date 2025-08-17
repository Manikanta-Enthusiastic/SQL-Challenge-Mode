-- SQL Script: This SQL script identifies the user(s) who have the most friends and the most friends number?

-- Step 1: Create the table to store friend request data
-- The table contains details about accepted friend requests
-- requester_id: ID of the user who sent the friend request
-- accepter_id: ID of the user who accepted the friend request
-- accept_date: The date when the request was accepted
-- Primary Key: A combination of requester_id and accepter_id ensures unique records
CREATE TABLE RequestAccepted (
    requester_id INT,                -- User who sent the friend request
    accepter_id INT,                 -- User who accepted the friend request
    accept_date DATE,                -- Date when the request was accepted
    PRIMARY KEY ( requester_id, 
                  accepter_id)       -- Ensures unique combinations of requester and accepter
);

-- Step 2: Insert sample data into the RequestAccepted table
-- The data represents friend requests and their acceptance dates
INSERT INTO RequestAccepted (requester_id, accepter_id, accept_date) VALUES
('1', '2', '2016-06-03'), 
('1', '3', '2016-06-08'),
('2', '3', '2016-06-08'), 
('3', '4', '2016-06-09'),
('1', '4', '2016-06-09'),
('2', '4', '2016-06-09'),
('5', '3', '2016-06-09'),
('5', '4', '2016-06-09');

-- Step 3: Combine all friendships into a single view
WITH Friends AS (
    SELECT                           -- Select the requester_id as id
        requester_id AS id
    FROM RequestAccepted
    UNION ALL                        -- Use UNION ALL to include the reverse relationship (accepter_id as user_id and requester_id as friend_id)
    SELECT 
        accepter_id AS id            -- Select the accepter_id as id
    FROM RequestAccepted
),                                  
    

-- Step 4: Count the number of friends for each user
FriendCount AS (
    SELECT                           -- For each user, calculate the total number of friends
        id,                          -- The ID of the user
        COUNT(id) AS num             -- Count the no of friends for each user
    FROM Friends
    GROUP BY user_id                 -- Group by each user to aggregate their friend count
),

-- Step 5: Determine the maximum number of friends
MaxFriends AS (
    SELECT 
        MAX(num) AS max_num          -- Find the highest friend count from the FriendCount CTE
    FROM FriendCount
)

-- Step 6: Retrieve the user(s) with the maximum number of friends
SELECT 
    id,                              -- The ID of the user with the most friends
    num                              -- The number of friends for this user
FROM FriendCount
WHERE num = ( SELECT 
                max_num 
              FROM MaxFriends);      -- Filter users whose friend count matches the maximum


-- End of query
