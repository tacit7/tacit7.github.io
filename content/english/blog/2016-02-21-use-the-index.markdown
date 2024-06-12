---
publishDate: "2016-02-21"
title: "Use the Index, Part 1"
category: SQL
tags: [SQL]
header:
  image: /images/use-the-index.jpg
excerpt: Use the Index! Is an online book that goes in-depth about how to use and create indexes. These are a few notes from the book.
---

## Anatomy of an SQL Index

I've been reading the amazing reference by Markus Winand, [Use the Index, Luke!](https://use-the-index-luke.com/)These are just a few notes from the website.

<figure class="half">
    <img src="/assets/images/use-the-index/use-the-index11.jpg">
</figure>
## Index Leaf Nodes

- **Primary Purpose of an Index**: Provides an ordered representation of the indexed data.
- **Challenge of Sequential Storage**: Storing data sequentially is impractical due to the need to move existing entries for new inserts, which is time-consuming and slows down the insert statement.
- **Solution**: Establish a logical order independent of physical memory order.
- **Doubly Linked List**:
  - Establishes logical order by linking each node to its two neighbors.
  - New nodes are inserted by updating links, not by moving data.
  - Allows reading the index forwards or backwards.
  - Used in many programming languages for collections (e.g., `java.util.LinkedList`, `System.Collections.Generic.LinkedList`, `std::list`).
- **Database Usage**:
  - Connects index leaf nodes using a doubly linked list.
  - Each leaf node is stored in a database block or page, which is the smallest storage unit.
  - Index blocks are of uniform size, storing as many entries as possible.
  - Maintains order at two levels: within each leaf node and among leaf nodes.

<figure class="half">
    <img src="/assets/images/use-the-index/use-the-index12.jpg">
</figure>
## Search Tree (B-Tree) Overview

- **Doubly Linked List and B-Tree**:
  - Doubly linked list establishes the logical order between leaf nodes.
  - B-tree’s root and branch nodes facilitate fast searching.
- **B-Tree Structure**:
  - **Branch Nodes**: Each branch node entry represents the largest value in its corresponding leaf node.
  - Example: If the largest value in a leaf node is 46, this value is stored in the branch node.
  - **Multiple Layers**: Branch nodes cover leaf nodes, and additional layers are built on top until all keys fit into a single root node.
  - **Balanced Tree**: The tree depth is equal at every position, ensuring consistent distance from the root to any leaf node.
- **Automatic Maintenance**:
  - The database maintains the index automatically.
  - It applies inserts, deletes, and updates to keep the B-tree balanced.
  - This results in maintenance overhead for write operations.

<figure class="half">
    <img src="/assets/images/use-the-index/use-the-index-13.jpg">
</figure>
- **Figure 1.3: Searching for a Key in a B-Tree**:[link](https://use-the-index-luke.com/sql/anatomy/the-tree)
  - **Search Example**: Finding the key “57”.
  - **Traversal Process**:
    - Start at the root node (left-hand side).
    - Process entries in ascending order until finding a value greater than or equal to (>=) the search term (57).
    - In the example, the key 83 is found to be >= 57.
    - Follow the reference from the key 83 to the corresponding branch node.
    - Repeat the procedure in the branch node.
    - Continue this process until reaching a leaf node.
- **Efficient Search**:
  - The structured traversal ensures quick location of the desired key within the B-tree.
- **Efficiency of Tree Traversal**:
  - Tree traversal is highly efficient, referred to as the "first power of indexing."
  - It operates almost instantly, even on large data sets.
- **Reasons for Efficiency**:
  - **Tree Balance**: Ensures access to all elements with the same number of steps.
  - **Logarithmic Growth**: Tree depth grows very slowly compared to the number of leaf nodes.
- **Real-World Indexes**:
  - Indexes with millions of records typically have a tree depth of four or five.
  - A tree depth of six is rarely seen.
- **Logarithmic Scalability**:
  - Explains the slow growth of tree depth relative to the number of leaf nodes.

## Slow Indexes, Part I

- **Efficiency and Exceptions**:

  - Despite efficient tree traversal, index lookups can sometimes be slower than expected.
  - This has led to the myth of the “degenerated index,” suggesting an index rebuild as a solution.

- **Myth of Index Rebuilds**:
  - Appendix B, “Myth Directory,” covers [this](https://use-the-index-luke.com/sql/myth-directory/indexes-can-degenerate) and other [myths](https://use-the-index-luke.com/sql/myth-directory).
  - Rebuilding an index does not improve long-term performance.
- **Causes of Slow Index Lookups**: - Explained by the structure and function of leaf nodes and tree traversal.

  - **Leaf Node Chain**:

    - Consider the search for “57” in Figure 1.3:
    - There are two matching entries in the index.
    - The next leaf node might contain additional entries for “57”.
    - The database *must* read the next leaf node to see if there are any more matching entries
    - The database also needs to follow the leaf node chain.

  - **Table Access**
    - A single leaf node might contain many hits.

    - And table data is scattered.
    - There is an additional table access for each hit.

    -**Index Lookup Process**:
    -Perform the tree traversal.
    -Follow the leaf node chain to check for more matching entries.

- The important point is that an INDEX RANGE SCAN can potentially read a large part of an index. If there is one more table access for each row, the query can become slow even when using an index.
