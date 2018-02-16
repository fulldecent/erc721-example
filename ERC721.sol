pragma solidity ^0.4.20;

import "./ERC165.sol";

/// @title Interface for contracts conforming to ERC-721: Deed Standard
/// @author William Entriken (https://phor.net), et. al.
/// @dev Specification at https://github.com/ethereum/eips/XXXFinalUrlXXX
interface ERC721 /* is ERC165 */ {

    // COMPLIANCE WITH ERC-165 (DRAFT) /////////////////////////////////////////

    // bytes4 internal constant INTERFACE_SIGNATURE_ERC165 = // 0x01ffc9a7
    //     this.supportsInterface.selector;

    /// @dev ERC-165 (draft) interface signature for itself
    // bytes4 internal constant INTERFACE_SIGNATURE_ERC721 = // xxxxxx
    //     this.ownerOf.selector ^
    //     this.countOfDeeds.selector ^
    //     this.countOfDeedsByOwner.selector ^
    //     this.deedOfOwnerByIndex.selector ^
    //     this.approve.selector ^
    //     this.takeOwnership.selector ^
    //     this.transfer.selector;

    // PUBLIC QUERY FUNCTIONS //////////////////////////////////////////////////

    /// @notice Find the owner of a deed
    /// @param _deedId The identifier for a deed we are inspecting
    /// @dev Deeds assigned to zero address are considered invalid, and
    ///  queries about them do throw.
    /// @return The non-zero address of the owner of deed `_deedId`, or `throw`
    ///  if deed `_deedId` is not tracked by this contract
    function ownerOf(uint256 _deedId) external view returns (address _owner);

    /// @notice Count deeds tracked by this contract
    /// @return A count of valid deeds tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function countOfDeeds() external view returns (uint256 _count);

    /// @notice Count all deeds assigned to an owner
    /// @dev Throws if `_owner` is the zero address, representing invalid deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @return The number of deeds owned by `_owner`, possibly zero
    function countOfDeedsByOwner(address _owner) external view returns (uint256 _count);

    /// @notice Enumerate deeds assigned to an owner
    /// @dev Throws if `_index` >= `countOfDeedsByOwner(_owner)` or if
    ///  `_owner` is the zero address, representing invalid deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @param _index A counter less than `countOfDeedsByOwner(_owner)`
    /// @return The identifier for the `_index`th deed assigned to `_owner`,
    ///   (sort order not specified)
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);

    // TRANSFER MECHANISM //////////////////////////////////////////////////////

    /// @dev This event emits when ownership of any deed changes by any
    ///  mechanism. This event emits when deeds are created (`from` == 0) and
    ///  destroyed (`to` == 0). Exception: during contract creation, any
    ///  transfers may occur without emitting `Transfer`. At the time of any transfer,
    ///  the "approved taker" is implicitly reset to the zero address.
    event Transfer(address indexed from, address indexed to, uint256 indexed deedId);

    /// @dev The Approve event emits to log the "approved taker" for a deed -- whether
    ///  set for the first time, reaffirmed by setting the same value, or setting to
    ///  a new value. The "approved taker" is the zero address if nobody can take the
    ///  deed now or it is an address if that address can call `takeOwnership` to attempt
    ///  taking the deed. Any change to the "approved taker" for a deed SHALL cause
    ///  Approve to emit. However, an exception, the Approve event will not emit when
    ///  Transfer emits, this is because Transfer implicitly denotes the "approved taker"
    ///  is reset to the zero address.
    event Approval(address indexed from, address indexed to, uint256 indexed deedId);

    /// @notice Set the "approved taker" for your deed, or revoke approval by
    ///  setting the zero address. You may `approve` any number of times while
    ///  the deed is assigned to you, only the most recent approval matters. Emits
    ///  an Approval event.
    /// @dev Throws if `msg.sender` does not own deed `_deedId` or if `_to` ==
    ///  `msg.sender` or if `_deedId` is not a valid deed.
    /// @param _deedId The deed for which you are granting approval
    function approve(address _to, uint256 _deedId) external payable;

    /// @notice Become owner of a deed for which you are currently approved
    /// @dev Throws if `msg.sender` is not approved to become the owner of
    ///  `deedId` or if `msg.sender` currently owns `_deedId` or if `_deedId is not a
    ///  valid deed.
    /// @param _deedId The deed that is being transferred
    function takeOwnership(uint256 _deedId) external payable;

    /// @notice Set a new owner for your deed
    /// @dev Throws if `msg.sender` does not own deed `_deedId` or if `_to` ==
    ///  `msg.sender` or if `_deedId` is not a valid deed.
    /// @param _deedId The deed that is being transferred
    function transfer(address _to, uint256 _deedId) external payable;
}

/// @title Metadata extension to ERC-721 interface
/// @author William Entriken (https://phor.net)
/// @dev Specification at https://github.com/ethereum/eips/issues/XXXX
interface ERC721Metadata {

    /// @dev ERC-165 (draft) interface signature for ERC721
    // bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata = // 0x2a786f11
    //     this.name.selector ^
    //     this.symbol.selector ^
    //     this.deedUri.selector;

    /// @notice A descriptive name for a collection of deeds managed by this
    ///  contract
    /// @dev Wallets and exchanges MAY display this to the end user.
    function name() external pure returns (string _name);

    /// @notice An abbreviated name for deeds managed by this contract
    /// @dev Wallets and exchanges MAY display this to the end user.
    function symbol() external pure returns (string _symbol);

    /// @notice A distinct URI (RFC 3986) for a given deed.
    /// @dev If:
    ///  * The URI is a URL
    ///  * The URL is accessible
    ///  * The URL points to a valid JSON file format (ECMA-404 2nd ed.)
    ///  * The JSON base element is an object
    ///  then these names of the base element SHALL have special meaning:
    ///  * "name": A string identifying the item to which `_deedId` grants
    ///    ownership
    ///  * "description": A string detailing the item to which `_deedId` grants
    ///    ownership
    ///  * "image": A URI pointing to a file of image/* mime type representing
    ///    the item to which `_deedId` grants ownership
    ///  Wallets and exchanges MAY display this to the end user.
    ///  Consider making any images at a width between 320 and 1080 pixels and
    ///  aspect ratio between 1.91:1 and 4:5 inclusive.
    ///  Throws if `_deedId` is not a valid deed.
    function deedUri(uint256 _deedId) external view returns (string _deedUri);
}

/// @title Enumeration extension to ERC-721 interface
/// @author William Entriken (https://phor.net)
/// @dev Specification at https://github.com/ethereum/eips/issues/XXXX
interface ERC721Enumerable {

    /// @dev ERC-165 (draft) interface signature for ERC721
    // bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable = // 0xa5e86824
    //     this.deedByIndex.selector ^
    //     this.countOfOwners.selector ^
    //     this.ownerByIndex.selector;

    /// @notice Enumerate active deeds
    /// @dev Throws if `_index` >= `countOfDeeds()`
    /// @param _index A counter less than `countOfDeeds()`
    /// @return The identifier for the `_index`th deed, (sort order not
    ///  specified)
    function deedByIndex(uint256 _index) external view returns (uint256 _deedId);

    /// @notice Count of owners which own at least one deed
    /// @return A count of the number of owners which own deeds
    function countOfOwners() external view returns (uint256 _count);

    /// @notice Enumerate owners
    /// @dev Throws if `_index` >= `countOfOwners()`
    /// @param _index A counter less than `countOfOwners()`
    /// @return The address of the `_index`th owner (sort order not specified)
    function ownerByIndex(uint256 _index) external view returns (address _owner);
}
