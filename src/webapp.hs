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

{- | Prepare the database for our data.

We create two tables and ask the database engine to verify some pieces
of data consistency for us:

* castid and epid both are unique primary keys and must never be duplicated
* castURL also is unique
* In the episodes table, for a given podcast (epcast), there must be only
  one instance of each given URL or episode ID
-}
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


{- | Adds a new episode to the database. 

Since this is done by automation, instead of by user request, we will
simply ignore requests to add duplicate episodes.  This way, when we are
processing a feed, each URL encountered can be fed to this function,
without having to first look it up in the DB.

Also, we generally won't care about the new ID here, so don't bother
fetching it. -}
addFood :: IConnection conn => conn -> Food -> IO ()
addFood dbh food =
    run dbh "INSERT INTO Food (name, energy, protein, fat, carbs) \
                \VALUES (?, ?, ?, ?, ?)"
    [toSql (name food),
     toSql (energy food),
     toSql (protein food),
     toSql (fat food),
     toSql (carbs food)]
                    >> return ()
       

{- | Modifies an existing episode.  Looks it up by ID and modifies the
database record to match the given episode. -}
updateFood :: IConnection conn => conn -> Food -> IO ()
updateFood dbh food =
    run dbh "UPDATE food SET energy = ?, protein = ?, fat = ?, carbs = ? WHERE name = ?"
             [toSql (energy food),
              toSql (protein food),
              toSql (fat food),
              toSql (carbs food),
              toSql (name food)]
    >> return ()


{- | Gets a list of all podcasts. -}
-- getPodcasts :: IConnection conn => conn -> IO [Podcast]
-- getPodcasts dbh =
--     do res <- quickQuery' dbh 
--               "SELECT castid, casturl FROM podcasts ORDER BY castid" []
--        return (map convPodcastRow res)

{- | Get a particular podcast.  Nothing if the ID doesn't match, or
Just Podcast if it does. -}
-- getPodcast :: IConnection conn => conn -> Integer -> IO (Maybe Podcast)
-- getPodcast dbh wantedId =
--     do res <- quickQuery' dbh 
--               "SELECT castid, casturl FROM podcasts WHERE castid = ?"
--               [toSql wantedId]
--        case res of
--          [x] -> return (Just (convPodcastRow x))
--          [] -> return Nothing
--          x -> fail $ "Really bad error; more than one podcast with ID"

{- | Convert the result of a SELECT into a Podcast record -}
-- convPodcastRow :: [SqlValue] -> Podcast
-- convPodcastRow [svId, svURL] =
--     Podcast {castId = fromSql svId,
--              castURL = fromSql svURL}
-- convPodcastRow x = error $ "Can't convert podcast row " ++ show x

