package edu.berkeley.cs186.database.contest;

import edu.berkeley.cs186.database.memory.EvictionPolicy;
import edu.berkeley.cs186.database.memory.LRUEvictionPolicy;
import edu.berkeley.cs186.database.memory.ClockEvictionPolicy;

public class ContestSetup {

    // Select your buffer eviction policy!
    public static final EvictionPolicy EVICTION_POLICY = new ClockEvictionPolicy();

    public static final String[][] INDICES_TO_BUILD = {
            // Format ("table", "column")
            // Examples:
            // {"customer", "c_custkey"},
            // {"part", "p_partkey"},
            {"customer", "c_custkey"},
            {"lineitem", "l_partkey"},
            {"orders", "o_orderkey"},
            {"part", "p_partkey"},
            {"partsupp", "ps_partkey"},
            {"supplier", "s_suppkey"},
    };
}
