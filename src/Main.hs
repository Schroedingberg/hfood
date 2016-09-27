
data Food  = Food {
  name :: String,
  -- Energy shall be only given in kJ. Showing everything in kcal might be made available as an option
  energy :: Float,
  -- Macronutrients shall be provided as fractions (so <= 1)
  protein :: Float,
  fat :: Float,
  carbs :: Float
                  } deriving (Show)
