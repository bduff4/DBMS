// 1. Over how many years was the unemployment data collected?
db.unemployment.distinct("Year").length

// 2. How many states were reported on in this dataset?
db.unemployment.distinct("State").length

// 3. What does this query compute? Answer: 657
db.unemployment.find({Rate : {$lt: 1.0}}).count()

// 4. Find all counties with unemployment rate higher than 10%.
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

// 7. Find the state with the highest unemployment rate. Hint. Use { $limit: 1 }
db.unemployment.aggregate([
  {
    $sort: {Rate: -1} // Sort records in descending order of Rate
  },
  {
    $limit: 1 // Limit the results to the top record
  },
  {
    $project: {State: 1, Rate: 1, _id: 0} // Display only State and Rate fields
  }
])

// 8. Count how many counties have an unemployment rate above 5%.
db.unemployment.find({Rate: {$gt: 5.0}}).count()

// 9. Calculate the average unemployment rate per state by year.
db.unemployment.aggregate([
  {
    $group: {
      _id: {State: "$State", Year: "$Year"}, // Group by State and Year
      averageRate: {$avg: "$Rate"} // Calculate the average of the Rate field
    }
  },
  {
    $sort: {"_id.Year": 1, "_id.State": 1} // Sort by Year and State for clarity
  }
])

// 10. For each state, calculate the total unemployment rate across all counties (sum of all county rates).
db.unemployment.aggregate([
  {
    $group: {
      _id: "$State", // Group by State
      totalRate: {$sum: "$Rate"} // Calculate the sum of Rate for each state
    }
  }
])

// 11. The same as Query 10 but for states with data from 2015 onward.
db.unemployment.aggregate([
  {
    $match: {Year: {$gte: 2015}} // Filter for records with Year >= 2015
  },
  {
    $group: {
      _id: "$State", // Group by State
      totalRate: {$sum: "$Rate"} // Calculate the sum of Rate for each state
    }
  }
])
