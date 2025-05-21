# log.nix Examples

This directory contains examples demonstrating how to use the log.nix library for various logging scenarios.

## Running Examples

To run these examples, you can use:

```bash
nix eval -f flake.nix examples.basic
nix eval -f flake.nix examples.advanced
nix eval -f flake.nix examples.modules
nix eval -f flake.nix examples.formats
```

## Example Files

- [basic.nix](./basic.nix) - Basic usage of different log levels
- [advanced.nix](./advanced.nix) - Advanced configuration examples
- [modules.nix](./modules.nix) - Module-specific logging with prefixes
- [formats.nix](./formats.nix) - Different output format examples (text vs JSON)

## Tips for Effective Logging

1. **Use appropriate log levels**:
   - `debug` for detailed troubleshooting
   - `info` for general operational information
   - `warn` for potential issues
   - `error` for actual errors

2. **Use prefixes** to identify which module is generating the log

3. **Use JSON format** when logs need to be processed by other tools

4. **Use custom templates** when you need specific formatting