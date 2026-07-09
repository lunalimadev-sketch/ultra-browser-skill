---
name: ascii-diagram
description: Create perfectly aligned ASCII art diagrams with box-drawing characters. Supports org charts, flowcharts, state machines, sequence diagrams, UML class diagrams, and architecture diagrams. Includes PLAN→DRAW→VERIFY workflow with automated verification scripts.
license: MIT
---

# ASCII Diagram Skill

Create properly aligned ASCII art diagrams with **two modes**:
- **Unicode mode** (default): Box-drawing characters (┌─┐│└┘▼) for better visual quality
- **ASCII mode**: Basic characters (+, -, |, v, ^, >, <) for maximum compatibility

## MANDATORY WORKFLOW

Every diagram MUST follow these three phases in order:

### Phase 1: PLAN

Before drawing, answer these questions:

1. **Max width?** Default: 80 chars, max: 100 chars
2. **How many boxes/elements?**
3. **What are the labels?** What is the longest label?
4. **Layout:** Top-down? Left-right? Nested?

**Calculate dimensions:**
- Box width = longest text + 2 (padding) + 2 (borders)
- Example: "Database" (8 chars) → 8 + 2 + 2 = 12 → `+------------+`

**Create a column ruler** for complex diagrams:
```
         1111111111222222222233333333334444444444
12345678901234567890123456789012345678901234567890
```

Mark where each vertical element will be placed.

### Phase 2: DRAW

Use the `grid.py` helper script for precise placement:

```python
import sys
sys.path.insert(0, '<skill_dir>/scripts')
from grid import Grid

# Unicode mode (default, better looking)
g = Grid(width=80, mode='unicode')

# Or ASCII mode (maximum compatibility)
# g = Grid(width=80, mode='ascii')

L = g.line()
g.put(L, 1, g.box_str('My Label'))     # Top border
g.emit(L)

L = g.line()
g.put(L, 1, g.box_label_str('My Label', 14))  # Label row
g.emit(L)

L = g.line()
g.put(L, 1, g.box_bottom('My Label'))  # Bottom border
g.emit(L)
```

**Character Rules:**
- Unicode mode: `┌ ┐ └ ┘ ─ │ ▼ ▲ ◀ ▶`
- ASCII mode: `+ - | v ^ < >`
- All related boxes at same level MUST have equal width
- Arrow `▼`/`v` MUST be centered under parent box
- `▼`/`v` = 1 char width (despite visual display being wider)

### Phase 3: VERIFY

Run the verifier on every diagram before presenting:

```bash
python3 <skill_dir>/scripts/verify.py < diagram.txt
```

The verifier checks:
1. **Unicode scan** — no banned characters
2. **Junction audit** — every `|` meeting a horizontal line has `+`
3. **Box consistency** — same-level boxes have equal width
4. **Arrow connectivity** — no floating arrows

After verify.py passes, do a **manual read-through**:
- Does the flow make sense?
- Any visual glitches?
- Any semantic errors?

## JUNCTION RULE (Critical)

**Every vertical line connecting to a horizontal line MUST have a junction character at that column:**

Unicode mode:
```
WRONG:                    RIGHT:
    │                         │
────────                  ────┬───
    │                         │
```

ASCII mode:
```
WRONG:                    RIGHT:
    |                         |
--------                  ----+---
    |                         |
```

**Unicode junction characters:**
- `┬` = T-junction top (horizontal + vertical from above)
- `┴` = T-junction bottom (horizontal + vertical from below)
- `├` = T-junction left (vertical + horizontal from left)
- `┤` = T-junction right (vertical + horizontal from right)
- `┼` = Cross (both horizontal and vertical pass through)

In ASCII mode, all junctions use `+`.

## BOX TEMPLATES

### Simple Box
```
+------------+
|   Label    |
+------------+
```

### Status Box (with second line)
```
+------------+
|   Agent    |
|  ✅ idle   |
+------------+
```

### Nested Container
```
+-----------------------------------------+
|            Container Name               |
|                                         |
|  +----------+    +----------+          |
|  |  Box A   |    |  Box B   |          |
|  +----------+    +----------+          |
|                                         |
+-----------------------------------------+
```

## DIAGRAM TEMPLATES

### Org Chart
```
                  +----------+
                  |   CEO    |
                  +----+-----+
                       |
          +------------+------------+
          |            |            |
     +----v----+  +----v----+  +----v----+
     | Worker 1 |  | Worker 2 |  | Worker 3 |
     +----------+  +----------+  +----------+
```

### Flowchart
```
+----------+
|  Start   |
+----+-----+
     |
     v
+----+-----+     +-----------+
| Process  |---->| Decision  |
+----------+     +-----+-----+
                      |
              +-------+-------+
              |               |
             Yes              No
              |               |
              v               v
         +----+----+    +----+----+
         | Path A  |    | Path B  |
         +---------+    +---------+
```

### Sequence Diagram
```
  Client          Server          Database
     |               |               |
     |  HTTP Request |               |
     |-------------->|               |
     |               |  SQL Query    |
     |               |-------------->|
     |               |    Results    |
     |               |<--------------|
     | JSON Response |               |
     |<--------------|               |
```

### State Machine
```
           +----------+
     +---->|  IDLE    |
     |     +----+-----+
     |          |
     |      event A
     |          |
     |          v
     |     +----+-----+
     |     | ACTIVE   |
     |     +----+-----+
     |          |
     |      event B
     |          |
     |          v
     |     +----+-----+
     +-----+  DONE    |
           +----------+
```

### UML Class Diagram
```
        +---------------------+
        |   <<interface>>     |
        |    EventEmitter     |
        +---------------------+
        | + on()              |
        | + emit()            |
        | + off()             |
        +----+-----------+----+
             ^           ^
             |           |
    +--------+--+   +----+--------+
    | HttpServer|   | WebSocket   |
    +------------+   +-------------+
    | - port     |   | - url       |
    +------------+   +-------------+
    | + listen() |   | + connect() |
    +------------+   +-------------+
```

### Architecture Diagram
```
+------------------------------------------------------+
|                  Web Application                     |
+------------------------------------------------------+
|                                                      |
|  +----------+              +-----------+            |
|  | Frontend |------------->|API Gateway|            |
|  +----------+              +-----+-----+            |
|                                    |                 |
|                                    v                 |
|                              +-----+-----+          |
|                              |  Backend  |          |
|                              +-----+-----+          |
|                                    |                 |
|                      +-------------+--------+       |
|                      |             |        |       |
|                      v             v        v       |
|                +-----+----+  +----+----+  +---+---+ |
|                | Database |  |  Cache  |  | Queue | |
|                +----------+  +---------+  +-------+ |
+------------------------------------------------------+
```

## COMMON MISTAKES

### Off-by-one alignment
```
WRONG:        RIGHT:
  |              |
--+---        ---+---
  |              |
```

### Inconsistent box widths
```
WRONG:                    RIGHT:
+--------+ +------+      +----------+ +----------+
| Short  | |Tiny  |      |  Short   | |   Tiny   |
+--------+ +------+      +----------+ +----------+
```

### Floating arrows
```
WRONG:        RIGHT:
+--------+    +--------+
| Box A  |    | Box A  |
+--------+    +---+----+
                   |
   (gap!)          v
+--------+    +---+----+
| Box B  |    | Box B  |
+--------+    +--------+
```

## WIDTH CALCULATOR

For Unicode mode, account for display width:
- ASCII char = 1 display width
- Emoji = 2 display width (but 1 char in grid.py)
- Box-drawing char = 1 display width

Example: "📝 Writer Agent"
- Emoji: 2 display width
- Text: " Writer Agent" = 14 display width
- Total: 16 display width
- Box: 16 + 2 padding + 2 borders = 20 chars

For ASCII mode, no special width calculation needed.

## QUICK REFERENCE

| Element | Unicode | ASCII |
|---------|---------|-------|
| Corner TL | ┌ | + |
| Corner TR | ┐ | + |
| Corner BL | └ | + |
| Corner BR | ┘ | + |
| Horizontal | ─ | - |
| Vertical | │ | \| |
| Arrow Down | ▼ | v |
| Arrow Up | ▲ | ^ |
| Arrow Right | ▶ | > |
| Arrow Left | ◀ | < |
| T-junction top | ┬ | + |
| T-junction bottom | ┴ | + |
| T-junction left | ├ | + |
| T-junction right | ┤ | + |
| Cross junction | ┼ | + |

## Constraints

- Maximum width: 100 characters (prefer 80)
- Maximum boxes: 15-20 (split diagram if more)
- Maximum nesting: 2-3 levels
- Always use spaces, never tabs
