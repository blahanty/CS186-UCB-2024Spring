// Task 2ii

db.movies_metadata.aggregate([
    {
        $project: {
            space_split: {
                $split: [
                    "$tagline",
                    " "
                ]
            }
        }
    },

    {
        $unwind: "$space_split"
    },

    {
        $project: {
            lowercase_all_split: {
                $toLower: {
                    $trim: {
                        input: "$space_split",
                        chars: ".,?!"
                    }
                }
            },
        }
    },

    {
        $project: {
            lowercase_all_split: 1,
            string_length: {$strLenCP: "$lowercase_all_split"},
        }
    },

    {
        $match: {string_length: {$gt: 3}}
    },

    {
        $group: {
            _id: "$lowercase_all_split",
            count: {$sum: 1}
        }
    },

    {
        $sort: {count: -1}
    },

    {
        $limit: 20
    }
]);