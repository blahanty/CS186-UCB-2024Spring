// Task 2iii

db.movies_metadata.aggregate([
    {
        $project: {
            budget: {
                $cond: {
                    if: {
                        $and: [
                            {$ne: ["$budget", false]},
                            {$ne: ["$budget", null]},
                            {$ne: ["$budget", ""]},
                            {$ne: ["$budget", undefined]}
                        ]
                    },
                    then: {
                        $round: [
                            {
                                $cond: {
                                    if: {$isNumber: "$budget"},
                                    then: "$budget",
                                    else: {
                                        $toInt: {
                                            $trim: {
                                                input: "$budget",
                                                chars: " USD\$"
                                            }
                                        }
                                    }
                                }
                            },
                            -7
                        ]
                    },
                    else: "unknown"
                }
            }
        }
    },

    {
        $group: {
            _id: "$budget",
            count: {$sum: 1}
        }
    },

    {
        $project: {
            _id: 0,
            budget: "$_id",
            count: 1
        }
    },

    {
        $sort: {budget: 1}
    }
]);