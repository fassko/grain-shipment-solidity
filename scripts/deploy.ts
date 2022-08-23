import { ethers } from "hardhat";

async function main() {
    const [owner, ukraine, russia, turkey, un] = await ethers.getSigners();

    const GrainExport = await ethers.getContractFactory("GrainExport");
    const grainExport = await GrainExport.deploy(
        ukraine.address,
        russia.address,
        turkey.address,
        un.address
    );

    await grainExport.deployed();

    console.log(`Deployed to ${grainExport.address}`);

    // Agreement
    await grainExport.connect(ukraine).sign();
    await grainExport.connect(russia).sign();
    await grainExport.connect(turkey).sign();
    await grainExport.connect(un).sign();

    console.log(await grainExport.getAgreementStatus());

    // Shipment
    await grainExport.connect(ukraine).createShipment("Egypt");
    await grainExport.connect(ukraine).leftUkraine(1);
    await grainExport.connect(turkey).arrivesInTurkey(1);
    await grainExport.connect(turkey).examined(1);
    await grainExport.connect(un).arrivedInDestination(1);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
