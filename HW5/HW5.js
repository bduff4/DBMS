// 1. Over how many years was the unemployment data collected?
db.unemployment.distinct("Year").length

// 2. How many states were reported on in this dataset?
db.unemployment.distinct("State").length

// 3. What does this query compute? Answer: 657
db.unemployment.find({Rate : {$lt: 1.0}}).count()

// 4. Find all counties with unemployment rate higher than 10%
db.unemployment.find(
  {Rate: {$gt: 10.0}}, // Filters for records with Rate > 10.0
  {County: 1, State: 1, Rate: 1, _id: 0} // Projects only County, State, and Rate fields
)

// 5. Calculate the average unemployment rate across all states.
db.unemployment.aggregate([
  {
    $group: {
      _id: null, // Group all records into a single bucket
      averageRate: {$avg: "$Rate"} // Calculate the average of the Rate field
    }
  }
])

// 6. Find all counties with an unemployment rate between 5% and 8%.
db.unemployment.find(
  {Rate: {$gte: 5.0, $lte: 8.0}}, // Filters for rates in the range [5.0, 8.0]
  {County: 1, State: 1, Rate: 1, _id: 0} // Projects County, State, and Rate fields
)