# [CLI Tool Name]

[Brief 1-2 sentence description of what this CLI tool does]

**Language**: [Python/Node.js/Go/Rust]
**Framework**: [Click/Commander/Cobra/Clap]

## Quick Start

Prerequisites:
- `[runtime]` >= [version]
- `[package-manager]` >= [version] (for development)

```bash
# Install from package manager
npm install -g [tool-name]        # or: pip install [tool-name]

# Verify installation
[tool-name] --version

# Get help
[tool-name] --help
```

## Common Commands

### Basic Usage
- `[tool-name] [command]` - Execute main command
- `[tool-name] --help` - Show help
- `[tool-name] --version` - Show version

### Subcommands
- `[tool-name] init` - Initialize new project/config
- `[tool-name] build` - Build/compile
- `[tool-name] deploy` - Deploy to target
- `[tool-name] config` - Manage configuration

### Options
- `-v, --verbose` - Verbose output
- `-q, --quiet` - Quiet mode (errors only)
- `--dry-run` - Preview without executing
- `--config <path>` - Custom config file
- `--format <format>` - Output format (json/yaml/table)

## Development

### Setup

```bash
git clone https://github.com/[org]/[tool-name]
cd [tool-name]

npm install                       # or: pip install -e ".[dev]"
npm link                          # Make CLI available locally

# Verify
[tool-name] --version
```

### Project Structure

```
[tool-name]/
├── bin/                          # Entry point (for npm)
│   └── cli.js
├── src/                          # Source code
│   ├── cli/
│   │   ├── index.ts             # CLI entry point
│   │   ├── commands/            # Command implementations
│   │   │   ├── init.ts
│   │   │   ├── build.ts
│   │   │   └── deploy.ts
│   │   ├── options.ts           # Shared options
│   │   └── help.ts              # Help text
│   ├── core/                    # Business logic
│   │   ├── builder.ts
│   │   └── deployer.ts
│   ├── config/                  # Configuration
│   │   ├── loader.ts
│   │   └── schema.ts
│   └── utils/
│       ├── logger.ts            # Console output
│       ├── spinner.ts           # Progress indicator
│       └── colors.ts            # Terminal colors
├── tests/
│   ├── unit/                    # Unit tests
│   └── e2e/                     # E2E command tests
├── docs/
│   └── commands/                # Per-command documentation
└── package.json                 # CLI metadata

```

**Key Files**:
- `src/cli/index.ts` - CLI entry point and command router
- `src/cli/commands/` - Command implementations
- `package.json` - CLI metadata (bin field)

## Command Implementation

### Command Structure (Click - Python)

```python
# src/cli/commands/build.py
import click
from pathlib import Path
from ..utils.logger import logger, spinner

@click.command()
@click.argument('source', type=click.Path(exists=True))
@click.option('--output', '-o', type=click.Path(), help='Output directory')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
@click.option('--watch', '-w', is_flag=True, help='Watch mode')
def build(source: str, output: str, verbose: bool, watch: bool):
    """Build the project from SOURCE directory."""

    logger.info(f"Building from {source}")

    with spinner("Compiling...") as sp:
        try:
            result = compile_project(source, output, verbose=verbose)
            sp.succeed(f"Built {result.file_count} files")
        except BuildError as e:
            sp.fail(f"Build failed: {e}")
            raise click.ClickException(str(e))

    if watch:
        logger.info("Watching for changes...")
        watch_and_rebuild(source, output)
```

### Command Structure (Commander - Node.js)

```typescript
// src/cli/commands/build.ts
import { Command } from 'commander'
import { logger, spinner } from '../utils/logger'
import { compile } from '../../core/builder'

export function registerBuildCommand(program: Command) {
  program
    .command('build <source>')
    .description('Build the project from source directory')
    .option('-o, --output <path>', 'Output directory')
    .option('-v, --verbose', 'Verbose output')
    .option('-w, --watch', 'Watch mode')
    .action(async (source: string, options) => {
      logger.info(`Building from ${source}`)

      const sp = spinner('Compiling...')
      try {
        const result = await compile(source, options.output, {
          verbose: options.verbose,
        })
        sp.succeed(`Built ${result.fileCount} files`)
      } catch (error) {
        sp.fail(`Build failed: ${error.message}`)
        process.exit(1)
      }

      if (options.watch) {
        logger.info('Watching for changes...')
        await watchAndRebuild(source, options.output)
      }
    })
}
```

## Configuration

### Config File

```yaml
# .tool-config.yaml
version: 1.0

build:
  source: ./src
  output: ./dist
  minify: true

deploy:
  target: production
  registry: https://registry.example.com

plugins:
  - name: custom-plugin
    enabled: true
```

### Loading Configuration

```typescript
// src/config/loader.ts
import { cosmiconfigSync } from 'cosmiconfig'
import { validateConfig } from './schema'

export function loadConfig(searchFrom?: string): Config {
  const explorer = cosmiconfigSync('tool')

  const result = explorer.search(searchFrom)

  if (!result) {
    return getDefaultConfig()
  }

  // Validate config schema
  const validated = validateConfig(result.config)

  return validated
}
```

## User Interface

### Output Formatting

```typescript
// src/utils/logger.ts
import chalk from 'chalk'

export const logger = {
  info: (msg: string) => console.log(chalk.blue('ℹ'), msg),
  success: (msg: string) => console.log(chalk.green('✔'), msg),
  warning: (msg: string) => console.log(chalk.yellow('⚠'), msg),
  error: (msg: string) => console.error(chalk.red('✖'), msg),
}
```

### Progress Indicators

```typescript
// src/utils/spinner.ts
import ora from 'ora'

export function spinner(text: string) {
  const sp = ora(text).start()

  return {
    succeed: (msg: string) => sp.succeed(msg),
    fail: (msg: string) => sp.fail(msg),
    update: (msg: string) => sp.text = msg,
  }
}
```

### Interactive Prompts

```typescript
// src/cli/commands/init.ts
import inquirer from 'inquirer'

export async function initCommand() {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'projectName',
      message: 'Project name:',
      validate: (input) => input.length > 0 || 'Required',
    },
    {
      type: 'list',
      name: 'template',
      message: 'Select template:',
      choices: ['basic', 'advanced', 'custom'],
    },
    {
      type: 'confirm',
      name: 'installDeps',
      message: 'Install dependencies?',
      default: true,
    },
  ])

  await createProject(answers)
}
```

### Table Output

```typescript
import Table from 'cli-table3'

function displayResults(results: Result[]) {
  const table = new Table({
    head: ['Name', 'Status', 'Duration'],
    colWidths: [30, 15, 15],
  })

  results.forEach((r) => {
    table.push([r.name, r.status, `${r.duration}ms`])
  })

  console.log(table.toString())
}
```

## Error Handling

### User-Friendly Errors

```typescript
// src/utils/errors.ts
export class CLIError extends Error {
  constructor(
    message: string,
    public suggestion?: string,
    public exitCode: number = 1
  ) {
    super(message)
    this.name = 'CLIError'
  }
}

export function handleError(error: unknown) {
  if (error instanceof CLIError) {
    logger.error(error.message)
    if (error.suggestion) {
      logger.info(`💡 ${error.suggestion}`)
    }
    process.exit(error.exitCode)
  }

  // Unexpected error
  logger.error('An unexpected error occurred')
  console.error(error)
  process.exit(1)
}
```

### Input Validation

```typescript
export function validateProjectName(name: string): void {
  if (!/^[a-z0-9-]+$/.test(name)) {
    throw new CLIError(
      `Invalid project name: ${name}`,
      'Use lowercase letters, numbers, and hyphens only'
    )
  }

  if (name.length > 50) {
    throw new CLIError(
      'Project name too long',
      'Maximum 50 characters'
    )
  }
}
```

## Testing

### Unit Tests

```typescript
// tests/unit/commands/build.test.ts
import { build } from '@/cli/commands/build'

describe('build command', () => {
  it('compiles source files', async () => {
    const result = await build('./test-fixtures/src', './output')

    expect(result.success).toBe(true)
    expect(result.fileCount).toBeGreaterThan(0)
  })

  it('throws error on invalid source', async () => {
    await expect(
      build('./nonexistent', './output')
    ).rejects.toThrow('Source directory not found')
  })
})
```

### E2E Command Tests

```typescript
// tests/e2e/build.e2e.test.ts
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

describe('build command (E2E)', () => {
  it('builds project via CLI', async () => {
    const { stdout, stderr } = await execAsync(
      'tool-name build ./fixtures/sample-project'
    )

    expect(stdout).toContain('Built')
    expect(stderr).toBe('')
  })

  it('shows help for invalid arguments', async () => {
    try {
      await execAsync('tool-name build')
    } catch (error) {
      expect(error.stderr).toContain('Missing required argument')
    }
  })
})
```

### Snapshot Testing

```typescript
// tests/unit/help.snapshot.test.ts
import { getHelpText } from '@/cli/help'

test('help text snapshot', () => {
  const help = getHelpText()
  expect(help).toMatchSnapshot()
})
```

## Distribution

### npm Package

```json
{
  "name": "tool-name",
  "version": "1.0.0",
  "bin": {
    "tool-name": "./bin/cli.js"
  },
  "files": [
    "bin",
    "dist",
    "README.md"
  ],
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build && npm test"
  }
}
```

### Python Package (PyPI)

```python
# setup.py
from setuptools import setup, find_packages

setup(
    name='tool-name',
    version='1.0.0',
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    entry_points={
        'console_scripts': [
            'tool-name=cli.main:cli',
        ],
    },
    install_requires=[
        'click>=8.0',
        'pyyaml>=6.0',
    ],
    python_requires='>=3.9',
)
```

### Homebrew Formula

```ruby
# Formula/tool-name.rb
class ToolName < Formula
  desc "Description of your tool"
  homepage "https://github.com/org/tool-name"
  url "https://github.com/org/tool-name/archive/v1.0.0.tar.gz"
  sha256 "..."

  depends_on "node" => :build

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tool-name --version")
  end
end
```

### Binary Releases (Go/Rust)

```bash
# Using GoReleaser
goreleaser release --rm-dist

# Using cargo-dist (Rust)
cargo dist build --artifacts all
```

## Documentation

### Help Text

```typescript
// src/cli/help.ts
export const HELP_TEXT = `
Usage: tool-name <command> [options]

Commands:
  init               Initialize new project
  build <source>     Build from source directory
  deploy             Deploy to target environment
  config             Manage configuration

Options:
  -h, --help         Show help
  -v, --version      Show version
  --verbose          Verbose output
  --config <path>    Custom config file

Examples:
  $ tool-name init
  $ tool-name build ./src --output ./dist
  $ tool-name deploy --target production

Documentation: https://github.com/org/tool-name#readme
`
```

### Man Pages (Unix)

```bash
# Generate man page
help2man ./bin/tool-name > tool-name.1

# Install
sudo cp tool-name.1 /usr/local/share/man/man1/
man tool-name
```

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4

      - run: npm ci
      - run: npm test
      - run: npm run build

      # Publish to npm
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

      # Create GitHub Release
      - uses: softprops/action-gh-release@v1
        with:
          files: dist/*
```

## Environment Variables

```bash
# CLI Configuration
TOOL_CONFIG_PATH=[~/.tool-config.yaml]    # Custom config location
TOOL_LOG_LEVEL=[info]                     # debug/info/warn/error
TOOL_NO_COLOR=[false]                     # Disable colored output

# API/Service Integration
TOOL_API_KEY=[your-api-key]
TOOL_API_ENDPOINT=[https://api.example.com]

# Cache
TOOL_CACHE_DIR=[~/.cache/tool-name]
TOOL_CACHE_TTL=[3600]                     # seconds
```

## Performance

### Caching

```typescript
// src/utils/cache.ts
import { join } from 'path'
import { readFile, writeFile, mkdir } from 'fs/promises'

const CACHE_DIR = join(os.homedir(), '.cache', 'tool-name')

export async function getCached<T>(key: string): Promise<T | null> {
  const path = join(CACHE_DIR, `${key}.json`)

  try {
    const data = await readFile(path, 'utf-8')
    const cached = JSON.parse(data)

    // Check TTL
    if (Date.now() - cached.timestamp > CACHE_TTL) {
      return null
    }

    return cached.value
  } catch {
    return null
  }
}

export async function setCache<T>(key: string, value: T): Promise<void> {
  await mkdir(CACHE_DIR, { recursive: true })

  const cached = {
    timestamp: Date.now(),
    value,
  }

  const path = join(CACHE_DIR, `${key}.json`)
  await writeFile(path, JSON.stringify(cached))
}
```

### Lazy Loading

```typescript
// Load heavy dependencies only when needed
let _compiler: typeof import('./compiler') | null = null

export async function getCompiler() {
  if (!_compiler) {
    _compiler = await import('./compiler')
  }
  return _compiler
}
```

## Troubleshooting

**Issue**: Command not found after installation

**Solution**:
```bash
# npm global install
npm list -g | grep tool-name          # Check if installed
which tool-name                        # Check PATH

# Fix: Add npm global bin to PATH
export PATH="$PATH:$(npm bin -g)"

# Python pip install
pip show tool-name                     # Check if installed
which tool-name                        # Check PATH

# Fix: Add pip bin to PATH
export PATH="$PATH:$(python -m site --user-base)/bin"
```

---

**Issue**: Slow startup time

**Solution**:
- Profile startup: `node --prof bin/cli.js`
- Lazy load dependencies
- Use native modules instead of large libraries
- Cache expensive operations

---

**Issue**: Configuration not loading

**Solution**:
```bash
# Check config search paths
tool-name config --show-paths

# Validate config syntax
tool-name config --validate

# Use explicit config path
tool-name --config ./custom-config.yaml
```

## Best Practices

1. **User Experience**
   - Clear, actionable error messages
   - Progress indicators for long operations
   - Confirmation prompts for destructive actions
   - Helpful suggestions when commands fail

2. **Performance**
   - Fast startup (<100ms for simple commands)
   - Lazy load dependencies
   - Cache expensive operations
   - Minimize bundle size

3. **Documentation**
   - Comprehensive `--help` text
   - Examples in help output
   - Man pages for Unix systems
   - Online documentation with tutorials

4. **Distribution**
   - Multiple installation methods (npm, pip, Homebrew, binaries)
   - Auto-update mechanism
   - Version compatibility checks
   - Graceful degradation for missing features

5. **Testing**
   - Unit tests for business logic
   - E2E tests for CLI commands
   - Snapshot tests for help text/output
   - Cross-platform testing (Windows, macOS, Linux)

6. **Security**
   - Never log sensitive data (API keys, passwords)
   - Validate all user inputs
   - Use secure defaults
   - Warn before destructive operations

7. **Compatibility**
   - Support LTS versions of runtime
   - Test on multiple platforms
   - Handle different terminal capabilities
   - Respect NO_COLOR environment variable
