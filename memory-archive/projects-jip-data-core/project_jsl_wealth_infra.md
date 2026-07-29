---
name: JSL Wealth AWS Infrastructure
description: All JIP Data Engine infra is on JSL Wealth AWS account 389517402998 — never on personal fie account 765425735663
type: project
---

All Jhaveri/JIP infrastructure MUST be on JSL Wealth AWS account `389517402998`. Never on the personal `fie` account `765425735663`.

**Why:** User explicitly requires complete separation — all connections, data, RDS, EC2 must be on JSL Wealth. The old `fie-db` RDS was on the personal account and has been replaced.

**How to apply:**
- EC2: `13.206.34.214` (i-0e3fdeca0fd082844), account 389517402998, key: `jsl-wealth-key.pem`
- RDS: `jip-data-engine` instance on account 389517402998, private only (no public access)
- RDS SG: `sg-05d36de4012b7603a` — allows only EC2 SG `sg-0215e4a4161ca4a12` on port 5432
- DB: PostgreSQL 16.9, db.t3.medium, 50GB gp3, encrypted at rest
- DB name: `data_engine`, user: `jip_admin`
- IAM user for CLI: `jip-deployer` (profile `jsl-wealth`)
- VPC: `vpc-070a59f3d15f253d6`, subnet group: `jip-data-engine-subnets`
- Old fie-db endpoint (`fie-db.c7osw6q6kwmw`) is DEPRECATED — do not use
- `fie-key.pem` does NOT work on .214 — always use `jsl-wealth-key.pem`
