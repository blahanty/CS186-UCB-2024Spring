// Task 1iii

db.ratings.aggregate([
    {
        $group: {
            _id: "$rating",
            count: {$sum: 1}
        }
    },

    {
        $project: {
            _id: 0,
            count: 1,
            rating: "$_id"
        }
    },

    {
        $sort: {rating: -1}
    }
]);