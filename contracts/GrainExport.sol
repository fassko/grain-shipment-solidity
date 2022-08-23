// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

enum ShipmentStatus {
    InUkraine, // Registered in Ukraine
    LeftUkraine, // Navigating in Black Sea
    ArrivedInTurkey, // Arrived in Turkey
    LeftTurkey, // Left Turkey
    ArrivedInDestinationCountry // Arrived to the destination country
}

struct Shipment {
    string destination;
    ShipmentStatus status;
}

contract GrainExport is Ownable {
    address private ukraine;
    address private russia;
    address private turkey;
    address private un;

    bool private ukraineSigned;
    bool private russiaSigned;
    bool private turkeySigned;
    bool private unSigned;

    event SignedByUkraine();
    event SignedByRussia();
    event SignedByTurkey();
    event SignedByUN();
    event AgreementSigned();

    uint256 private currentShipmentId;

    mapping(uint256 => Shipment) shipments;

    event ShipmentCreated(uint256 shipmentId);
    event ShipmentLeftUkraine(uint256 shipmentId);
    event ShipmentArrivedInTurkey(uint256 shipmentId);
    event ShipmentExamined(uint256 shipmentId);
    event ShipmentArrivedInDestination(uint256 shipmentId, string destination);

    modifier agreementSigned() {
        require(ukraineSigned, "Ukraine not signed");
        require(russiaSigned, "Russia not signed");
        require(turkeySigned, "Turkey not signed");
        require(unSigned, "United Nations not signed");
        _;
    }

    constructor(
        address _ukraine,
        address _russia,
        address _turkey,
        address _un
    ) {
        ukraine = _ukraine;
        russia = _russia;
        turkey = _turkey;
        un = _un;
    }

    function sign() external {
        console.log("Signer address", msg.sender);

        require(
            msg.sender == ukraine ||
                msg.sender == russia ||
                msg.sender == turkey ||
                msg.sender == un,
            "Unknown signer"
        );

        if (msg.sender == ukraine) {
            ukraineSigned = true;
            console.log("Ukraine signed");
            emit SignedByUkraine();
        }

        if (msg.sender == russia) {
            russiaSigned = true;
            console.log("Russia signed");
            emit SignedByRussia();
        }

        if (msg.sender == turkey) {
            turkeySigned = true;
            console.log("Turkey signed");
            emit SignedByTurkey();
        }

        if (msg.sender == un) {
            unSigned = true;
            console.log("United Nations signed");
            emit SignedByUN();
        }

        if (ukraineSigned && russiaSigned && turkeySigned && unSigned) {
            emit AgreementSigned();
        }
    }

    function getAgreementStatus() external view {
        console.log("Ukraine signed", ukraineSigned);
        console.log("Russia signed", russiaSigned);
        console.log("Turkey signed", turkeySigned);
        console.log("United Nations signed", unSigned);
    }

    // -- Shipment -- //
    function getShipment(uint256 shipmentId)
        external
        view
        returns (Shipment memory)
    {
        console.log("Destination", shipments[shipmentId].destination);
        console.log("Destination", uint256(shipments[shipmentId].status));

        return shipments[shipmentId];
    }

    function createShipment(string memory _destination)
        external
        agreementSigned
    {
        require(msg.sender == ukraine, "Caller is not Ukraine");

        currentShipmentId++;
        shipments[currentShipmentId] = Shipment(
            _destination,
            ShipmentStatus.InUkraine
        );

        console.log("Shipment created", currentShipmentId);
        emit ShipmentCreated(currentShipmentId);
    }

    function leftUkraine(uint256 shipmentId) external agreementSigned {
        require(msg.sender == ukraine, "Caller is not Ukraine");

        shipments[shipmentId].status = ShipmentStatus.LeftUkraine;

        console.log("Shipment left Ukraine", shipmentId);
        emit ShipmentLeftUkraine(shipmentId);
    }

    function arrivesInTurkey(uint256 shipmentId) external agreementSigned {
        require(msg.sender == turkey, "Caller is not Turkey");

        shipments[shipmentId].status = ShipmentStatus.ArrivedInTurkey;

        console.log("Shipment arrived in Turkey", shipmentId);
        emit ShipmentArrivedInTurkey(shipmentId);
    }

    function examined(uint256 shipmentId) external agreementSigned {
        require(msg.sender == turkey, "Caller is not Turkey");

        shipments[shipmentId].status = ShipmentStatus.LeftTurkey;

        console.log("Shipment examined", shipmentId);
        emit ShipmentExamined(shipmentId);
    }

    function arrivedInDestination(uint256 shipmentId) external agreementSigned {
        require(msg.sender == un, "Caller is not United Nations");

        shipments[shipmentId].status = ShipmentStatus
            .ArrivedInDestinationCountry;

        console.log(
            "Shipment",
            shipmentId,
            "arrived in",
            shipments[shipmentId].destination
        );
        emit ShipmentArrivedInDestination(
            shipmentId,
            shipments[shipmentId].destination
        );
    }
}
