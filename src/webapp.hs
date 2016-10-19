module Webapp where

import Database.HDBC
import Database.HDBC.Sqlite3
import Foodtypes
import Control.Monad(when)
import Data.List(sort)

-- | Initialize DB and return database Connection
connect :: FilePath -> IO Connection
connect fp =
    do dbh <- connectSqlite3 fp
       prepDB dbh
       return dbh

-- Prepare the database for our data.
prepDB :: IConnection conn => conn -> IO ()
prepDB dbh =
  do tables <- getTables dbh
     when (not ("Food" `elem` tables)) $
       do run dbh "CREATE TABLE Food (\
                       \name TEXT NOT NULL UNIQUE,\
                       \energy INTEGER NOT NULL,\
                       \protein INTEGER NOT NULL,\
                       \fat INTEGER NOT NULL ,\
                       \carbs INTEGER NOT NULL)" []
          return ()
     commit dbh



-- addFood :: IConnection conn => conn -> Food -> IO ()
-- addFood dbh food =
--     run dbh "INSERT INTO Food (name, energy, protein, fat, carbs) \
--                 \VALUES (?, ?, ?, ?, ?)"
--     [toSql (name food),
--      toSql (energy food),
--      toSql (protein food),
--      toSql (fat food),
--      toSql (carbs food)]
--                     >> return ()
       

-- updateFood :: IConnection conn => conn -> Food -> IO ()
-- updateFood dbh food =
--     run dbh "UPDATE food SET energy = ?, protein = ?, fat = ?, carbs = ? WHERE name = ?"
--              [toSql (energy food),
--               toSql (protein food),
--               toSql (fat food),
--               toSql (carbs food),
--               toSql (name food)]
--     >> return ()


