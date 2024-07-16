// Task 1ii

db.movies_metadata.aggregate([
    {
        $match: {
            $and: [
                {vote_count: {$gte: 50}},
                {genres: {$elemMatch: {name: "Comedy"}}}
            ]
        }
    },

    {
        $project: {
            _id: 0,
            title: 1,
            vote_average: 1,
            vote_count: 1,
            movieId: 1
        }
    },

    {
        $sort:
            {
                vote_average: -1,
                vote_count: -1,
                movieId: 1
            }
    },

    {
        $limit: 50
    }
]);