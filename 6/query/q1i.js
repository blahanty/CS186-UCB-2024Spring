// Task 1i

db.keywords.aggregate([
    {
        $match: {
            $or: [
                {keywords: {$elemMatch: {name: "mickey mouse"}}},
                {keywords: {$elemMatch: {name: "marvel comic"}}}
            ]
        }
    },

    {
        $project: {
            _id: 0,
            keywords: 0
        }
    },

    {
        $sort: {movieId: 1}
    }
]);