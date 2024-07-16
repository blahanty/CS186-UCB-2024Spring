// Task 3i

db.credits.aggregate([
    {
        $unwind: "$cast"
    },

    {
        $match: {"cast.id": 7624}
    },

    {
        $lookup: {
            from: "movies_metadata",
            localField: "movieId",
            foreignField: "movieId",
            as: "movies"
        }
    },

    {
        $project: {
            _id: 0,
            title: "$movies.title",
            release_date: "$movies.release_date",
            character: "$cast.character"
        }
    },

    {
        $unwind: "$title"
    },

    {
        $unwind: "$release_date"
    },

    {
        $sort: {release_date: -1}
    }
]);