EmporiumRP Modular Diagnostic Suite Version: v2.3.1 Author: Meth Monsignor License: MIT + Lore Attribution

Overview
This tool audits Garry's Mod addons for integrity, provenance, and compliance. It scans for common backdoor patterns, remote execution hooks, obfuscation, and licensing violations. Designed for server admins, modders, and educators, it supports modular triggers, readable logs, and lore-friendly branding.

Features
Multi-addon scanning with summary reporting

Configurable whitelist logic and manual triggers

Debug scaffolding for stepwise inspection

Log-to-file support with timestamped entries

Compliance checks for GMod EULA and Steam Workshop

Licensing header detection and attribution tracking

Modular command suite integration

Philosophy
This scanner is not a ban tool. It is a teaching tool. It exists to empower admins and modders to audit, understand, and improve their systems collaboratively. Every flagged pattern is an invitation to investigate—not to accuse. False positives are expected and documented.

Usage
Place addons inside the place_addons_here/ directory. Run the scanner via the scan_addons.lua entry point or trigger manually using the integrated command suite. Review logs in logs/ and consult the README_FLAGS.md for pattern definitions.

Ethical Governance
No flagged addons are included in this repository

All patterns are documented and open to review

Attribution is preserved wherever possible

Licensing headers are respected and reinforced

Contributions must follow the EmporiumRP Code of Conduct

Licensing
This project is licensed under MIT with additional lore attribution. You are free to use, modify, and redistribute this tool, provided you retain authorship and respect the narrative branding. See LICENSE.md for details.

Contributing
Pull requests are welcome. Please review CONTRIBUTING.md and SECURITY.md before submitting. All contributions must be modular, documented, and ethically scoped.

*Important*

Place the .lua script in garrysmod/lua/autorun/server, list your addon folder names in local addonFolders = { "your_folder_1", "your_folder_2" }, then run run_integrity_scan from your server’s control panel console—not the in-game console—to execute the scan.
