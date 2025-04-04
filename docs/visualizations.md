# Git Monkey Visualizations

Git Monkey includes powerful visualization tools that make Git more intuitive and engaging through theme-specific ASCII art and animations. All visualizations are enhanced with educational explanations that adapt to the user's experience level (tone stage).

## Educational Approach

Git Monkey's visualizations follow a tone-aware educational approach:

- **Beginners (Tone Stages 0-1)**: Receive friendly, detailed explanations with examples, addressing them by name and breaking down complex concepts into simple metaphors.
  
- **Intermediate Users (Tone Stages 2-3)**: Get more concise explanations that still provide context, but assume some familiarity with Git concepts.
  
- **Advanced Users (Tone Stages 4-5)**: Visualizations appear without lengthy explanations, focusing on providing efficient information for experienced users.

## Branch Relationship Map

The branch relationship map provides a visual representation of how branches in your repository relate to each other.

```bash
gitmonkey visualize
# or
gitmonkey visualize --mode=branches
```

### Features

- Shows which branches are ahead or behind others
- Visualizes merge relationships between branches 
- Highlights your current branch
- Adapts visualization style to your selected theme

### Theme-Specific Visualizations

- **Jungle**: Vines and trees connect branches with monkey-themed relationships
- **Hacker**: Network-style node map with technical format
- **Wizard**: Mystical spellbook with magical connections
- **Cosmic**: Celestial representations with planets and stars

## Commit Heatmap

The commit heatmap shows your coding activity over time with visual indicators for commit frequency.

```bash
gitmonkey visualize --mode=heatmap
```

### Options

- `--since='1 month ago'` - Filter commits by time period
- `--branch=main` - Filter commits to a specific branch
- `--all` - Show all commit information

### Theme-Specific Visualizations

- **Jungle**: Banana growth chart with different plant stages
- **Hacker**: Matrix-style intensity blocks
- **Wizard**: Magical intensity symbols for spell casting
- **Cosmic**: Star brightness levels for cosmic events

## Time-Travel Snapshot Comparison

Compare project states across different commits with a visual directory structure comparison.

```bash
gitmonkey visualize --mode=snapshots
```

### Options

- `--branch=main` - Compare with specific branch
- `--count=5` - Compare with specific number of commits back

### Theme-Specific Visualizations

- **Jungle**: Jungle time vines with banana references
- **Hacker**: Temporal codebase differentiator with system status
- **Wizard**: Magical timeline scrying with arcane references
- **Cosmic**: Temporal cosmic shift across dimensions

## Animated Merge Visualization

When merging branches, Git Monkey provides an animated visualization of the process.

```bash
# Automatically used when merging
gitmonkey branch merge feature-branch main
```

### Theme-Specific Animations

- **Jungle**: A monkey swinging between branch trees
- **Hacker**: Data transfer between nodes in the network
- **Wizard**: A magical spell transferring essence between scrolls
- **Cosmic**: Interstellar transfer between cosmic bodies

## Commands and Options

```bash
# Basic visualization (shows branch relationships)
gitmonkey visualize

# Choose visualization type
gitmonkey visualize --mode=branches
gitmonkey visualize --mode=heatmap
gitmonkey visualize --mode=snapshots

# Filter options
gitmonkey visualize --branch=feature-branch
gitmonkey visualize --count=10
gitmonkey visualize --since='2 weeks ago'
gitmonkey visualize --all

# Disable animations
gitmonkey visualize --no-animate
```

## Integrating with Regular Git Workflow

Git Monkey's visualizations integrate naturally with your regular Git workflow:

1. **After creating branches**: See the branch relationship map
2. **Before merging**: Check branch relationships and commit differences
3. **During merging**: View the animated merge process
4. **After completing work**: Review the commit heatmap to see activity
5. **When exploring history**: Use time-travel snapshots to understand changes

These visualizations make Git more intuitive and help you better understand the state and history of your repository.