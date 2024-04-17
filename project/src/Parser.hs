module Parser where

import Data.Csv
import qualified Data.ByteString.Lazy as BL
import qualified Data.Vector as V

type CsvRow = (Double, Double)


groupAt :: Int -> [a] -> [[a]]
groupAt n = go
  where go [] = []
        go xs = ys : go zs
            where ~(ys, zs) = splitAt n xs


parserCsvGrouped :: FilePath -> IO ([[Double]], [[Double]])
parserCsvGrouped filePath = do
    csvData <- BL.readFile filePath
    case decode NoHeader csvData of
        Left err -> error err
        Right v ->
            let xs = V.toList (V.map fst v)
                ys = V.toList (V.map snd v)
                groupedXs = groupAt 1000 xs
                groupedYs = groupAt 1000 ys
            in return (groupedXs, groupedYs)

parserCsv :: FilePath -> IO [[Double]]
parserCsv filePath = do
    csvData <- BL.readFile filePath
    case decode NoHeader csvData :: Either String (V.Vector CsvRow) of
        Left err -> error err
        Right v -> return $ map (\(x, y) -> [x, y]) (V.toList v)


parserCsvNotGrouped :: FilePath -> IO ([Double], [Double])
parserCsvNotGrouped filePath = do
    csvData <- BL.readFile filePath
    case decode NoHeader csvData :: Either String (V.Vector CsvRow) of
        Left err -> error err
        Right v -> do
            let (xs, ys) = V.foldr' (\(x, y) (accX, accY) -> (x : accX, y : accY)) ([], []) v
            return (xs, ys)


parserCsvNotGroupedOne :: FilePath -> IO [[Double]]
parserCsvNotGroupedOne filePath = do
    csvData <- BL.readFile filePath
    case decode NoHeader csvData :: Either String (V.Vector CsvRow) of
        Left err -> error err
        Right v -> do
            let (xs, ys) = V.foldr' (\(x, y) (accX, accY) -> (x : accX, y : accY)) ([], []) v
            return [reverse xs, reverse ys]
