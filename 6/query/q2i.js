// Task 2i

db.movies_metadata.aggregate([
    {
        $project: {
            _id: 0,
            title: 1,
            vote_count: 1,
            score: {
                $round: [
                    {
                        $divide: [
                            {
                                $add: [
                                    {
                                        $multiply: [
                                            "$vote_count",
                                            "$vote_average"
                                        ]
                                    },
                                    {
                                        $multiply: [
                                            1838,
                                            7
                                        ]
                                    }
                                ]
                            },
                            {
                                $add: [
                                    "$vote_count",
                                    1838
                                ]
                            }
                        ]
                    },
                    2
                ]
            }
        }
    },

    {
        $sort: {
            score: -1,
            vote_count: -1,
            title: 1
        }
    },

    {
        $limit: 20
    }
]);