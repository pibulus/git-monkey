# 🐒 Git Monkey – Guiding Principles for a Friendlier Git CLI

## 🔮 Core Philosophy

Git Monkey exists to make Git feel human, helpful, and forgiving—not hostile, cryptic, or arcane. It's not just a tool; it's a translator, a guide, and a companion. Every command, prompt, and error response should reflect this ethos.

Git Monkey meets users where they are—whether they're taking their first steps or merging like a wizard.

---

## 🧠 Smart Contextual Help & Autoresponse

### 🧩 Problem:
Git throws dense, intimidating errors for common situations—missing upstreams, dirty trees, detached HEADs, diverged branches. Most users either:
- Don't understand the error
- Have to Google the solution (and hope the advice isn't outdated)
- Or make a mess trying to guess a fix

### 🐵 Git Monkey Solution:
Whenever a **known friction point** is encountered:

**[Step 1] Detect the Context**  
What is the user trying to do?  
What is Git confused or upset about?

**[Step 2] Explain It Clearly**  
Use plain, emotionally intelligent language. Reframe fear into clarity.

Example:  
"🐒 Looks like this branch hasn't been pushed before. That's why Git is panicking.  
Want me to link it to origin/your-branch and push it for you?"

**[Step 3] Offer a Smart Fix**  
- Present a safe Y/n prompt (default yes).
- Allow power users to bypass with `--yes` or `--auto`.
- Show the command that will be run (educational & reassuring).
- Allow user to copy it instead of running if they choose.

**[Step 4] Execute and Confirm**  
- Run the fix safely with progress feedback.
- Confirm success with delight.

Example:  
✅ "All done! Your branch now tracks origin/your-branch. Pushed successfully."

---

## 🏗️ Pattern Template (internal rule)

1. Detect issue  
2. Friendly message:  
   "🐒 Looks like you're in [context]. Here's what that means..."
3. Offer fix:  
   "Want me to [solution]? (Y/n)"
4. If yes, run fix and show confirmation.
5. Optional: --yes / --auto to skip prompt
6. Optional: --explain for deeper learning mode

---

## 🔁 Common Git Friction Points to Handle This Way

- `git push` with no upstream ➜ Offer `--set-upstream`
- Switching branches with uncommitted changes ➜ Offer to `stash`, `apply`, or use a `worktree`
- Detached HEAD ➜ Explain clearly, offer to reattach or create a new branch
- Diverged branches ➜ Offer safe `rebase`, `merge`, or open diff viewer
- Missing remotes ➜ Offer to add one from GitHub/GitLab origin
- Submodule errors ➜ Offer to run `git submodule update --init`
- Rebase conflict ➜ Show resolution steps with calm, friendly walkthrough
- `git clean` ➜ Warn before destructive actions, explain impact
- Stuck merges ➜ Detect and guide users step by step

---

## ✨ Enhancements

- Contextual aliases based on tone_stage (e.g., suggest "merge-magic" alias after 10 merges)
- `--explain` flag to temporarily turn on learning mode: show what's happening under the hood
- `--show-command` flag to output only the actual Git command being run
- `--why` flag for nerds who want to know why Git is throwing that error

---

## 🌿 Progressive Disclosure

When implementing Git Monkey commands, follow these principles of progressive disclosure:

1. **Start Simple, Reveal Complexity Gradually**
   - First exposure: Show only what's necessary
   - Subsequent uses: Introduce more advanced options
   - Power users: Provide shortcuts and advanced flags

2. **Three Levels of Detail**
   - Basic: Essential information with clear next steps
   - Standard: More context and options
   - Advanced: Complete details for power users with `--verbose` flag

3. **Remember User Progress**
   - Track command usage frequency
   - Adjust verbosity based on experience
   - Offer more advanced tips as users grow

Example progression:
```
# First-time user
🐒 Created worktree for 'feature-branch'

# A few uses later
🐒 Created worktree for 'feature-branch'
💡 Tip: Use 'gitmonkey worktree:switch feature-branch' to jump to it

# Power user
🐒 Created worktree for 'feature-branch'
💡 Pro tip: You can use '-y' flag to skip confirmations
```

---

## 🎨 Design Language & Tone

### Emojis as Intuitive Signifiers

- 🐒 = Git Monkey speaking/explaining
- ✅ = Success confirmation
- ❌ = Error that needs attention
- 💡 = Tip or educational information
- ⚠️ = Warning about potential issues
- 🔄 = Process in progress
- 🎉 = Celebration of completion
- 🧠 = Learning moment
- 🔍 = Searching or investigation

### Voice & Tone Principles

1. **Friendly but Professional**
   - Conversational but not overly casual
   - Respectful of user's time and intelligence
   - No excessive jokes that might frustrate in serious situations

2. **Calm During Crises**
   - More serious tone when handling potential data loss
   - Clear, step-by-step guidance during complex operations
   - Reassuring without minimizing legitimate concerns

3. **Encouraging Learning**
   - Frame mistakes as learning opportunities
   - Provide educational content contextually
   - Celebrate progress and skill development

4. **Cultural Sensitivity**
   - Avoid idioms that may not translate globally
   - Use inclusive language
   - Focus on universal experiences of coding joy and frustration

---

## 🛠️ Implementation Guidelines

### Command Structure

All Git Monkey commands should follow a consistent structure:

1. **Help/Usage First**
   - If no arguments or `--help`, display usage information
   - Include examples for common use cases

2. **Validate Environment**
   - Check if in Git repository
   - Verify required dependencies
   - Validate arguments

3. **Smart Default Behavior**
   - Choose sensible defaults that work in most cases
   - Make destructive operations opt-in, not opt-out

4. **Consistent Flag Patterns**
   - `--yes/-y` for auto-confirming prompts
   - `--force/-f` for overriding safety checks
   - `--verbose/-v` for additional information
   - `--quiet/-q` for minimal output

5. **Exit Codes & Error Handling**
   - Use standard exit codes consistently
   - Always handle errors gracefully with helpful messages
   - Provide recovery suggestions for common errors

---

## 🌱 Ultimate Goal

Every time a user hits a wall, Git Monkey builds a bridge—
With clarity, safety, charm, and a hint of monkey magic.

If Git is a jungle, Git Monkey is your machete, your guide, and your best friend in a little explorer hat.