# GSD Context

## Business requirement

Create a Fabric analytics solution for Contoso Retail that demonstrates a medallion-style data workflow for sales.

## Technical intent

Represent the Fabric solution as code and move it through a DevOps workflow:

1. Define the desired change in GSD.
2. Ask Copilot/agent to generate or modify item definitions.
3. Validate structure and conventions locally.
4. Commit changes to Git.
5. Promote to a target workspace through CI/CD.

## Target Fabric items

- `SalesLakehouse.Lakehouse`
- `SalesIngestionPipeline.DataPipeline`
- `TransformSales.Notebook`
- `SalesModel.SemanticModel`
- `SalesReport.Report`

## Non-goals

- Build a production-grade semantic model.
- Cover every Fabric item type.
- Replace native Fabric ALM features.
- Claim GSD is a Fabric standard.

## Message for the audience

Fabric as Code is not just exporting JSON. The differentiator is the operating model:

```text
Intent + Context + Plan + Validation + Deployment
```

GSD provides the operating model. Fabric provides the deployable item definitions.
