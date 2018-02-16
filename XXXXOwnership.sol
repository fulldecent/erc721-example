pragma solidity ^0.4.20;

//TODO: fix _owners and _owner similar variable names

import "./ERC721.sol";

/// @title Compliance with ERC-721 (draft) for xxxx xxxx
/// @author William Entriken (https://phor.net)
/// @dev See xxxx xxxx contract documentation for detail on how contracts interact.
contract XXXXOwnership is ERC721, ERC721Metadata, ERC721Enumerable {

// COMPLY WITH ERC165 in a separate linked contract in your project
function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
    return false;
}

    // COMPLIANCE WITH ERC721 (DRAFT) //////////////////////////////////////////

    /// @notice Find the owner of a deed
    /// @param _deedId The identifier for a deed we are inspecting
    /// @dev Deeds assigned to zero address are considered invalid, and
    ///  queries about them do throw.
    /// @return The non-zero address of the owner of deed `_deedId`, or `throw`
    ///  if deed `_deedId` is not tracked by this contract
    function ownerOf(uint256 _deedId)
        external
        view
        mustBeValidDeed(_deedId)
        returns (address _owner)
    {
        _owner = _ownerOfWithSubstitutions[_deedId];
        // Handle substitutions
        if (_owner == address(0)) {
            _owner = address(this);
        }
    }

    /// @notice Count deeds tracked by this contract
    /// @return A count of valid deeds tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function countOfDeeds() external view returns (uint256 _count) {
        return _countOfDeeds;
    }

    /// @notice Count all deeds assigned to an owner
    /// @dev Throws if `_owner` is the zero address, representing invalid deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @return The number of deeds owned by `_owner`, possibly zero
    function countOfDeedsByOwner(address _owner) external view returns (uint256 _count) {
        require(_owner != address(0));
        return _deedsOfOwnerWithSubstitutions[_owner].length;
    }

    /// @notice Enumerate deeds assigned to an owner
    /// @dev Throws if `_index` >= `countOfDeedsByOwner(_owner)` or if
    ///  `_owner` is the zero address, representing invalid deeds.
    /// @param _owner An address where we are interested in deeds owned by them
    /// @param _index A counter less than `countOfDeedsByOwner(_owner)`
    /// @return The identifier for the `_index`th deed assigned to `_owner`,
    ///   (sort order not specified)
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId) {
        require(_owner != address(0));
        _deedId = _deedsOfOwnerWithSubstitutions[_owner][_index];
        // Handle substitutions
        if (_owner == address(this)) {
            if (_deedId == 0) {
                _deedId = _index + 1;
            }
        }
    }

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
    function approve(address _to, uint256 _deedId) external payable {
        assert(msg.sender != address(this)); // Therefore skip substitutions
        require(_ownerOfWithSubstitutions[_deedId] == msg.sender);
        _approvedOf[_deedId] = _to;
        Approval(msg.sender, _to, _deedId);
    }

    /// @notice Become owner of a deed for which you are currently approved
    /// @dev Throws if `msg.sender` is not approved to become the owner of
    ///  `deedId` or if `msg.sender` currently owns `_deedId` or if `_deedId is not a
    ///  valid deed.
    /// @param _deedId The deed that is being transferred
    function takeOwnership(uint256 _deedId)
        external
        mustBeValidDeed(_deedId)
        payable
    {
        require(msg.sender == _approvedOf[_deedId]);
        assert(msg.sender != address(0)); // Therefore skip substitutions
        require (_ownerOfWithSubstitutions[_deedId] != msg.sender);
        _transfer(_deedId, msg.sender);
    }

    function transfer(address _to, uint256 _deedId) external payable{
        require(false);
    }

    // COMPLIANCE WITH ERC721Metadata (DRAFT) //////////////////////////////////

    /// @notice A descriptive name for a collection of deeds managed by this
    ///  contract
    /// @dev Wallets and exchanges MAY display this to the end user.
    function name() external pure returns (string _name) {
        return "XXXX XXXX";
    }

    /// @notice An abbreviated name for deeds managed by this contract
    /// @dev Wallets and exchanges MAY display this to the end user.
    function symbol() external pure returns (string _symbol) {
        return "XX";
    }

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
    function deedUri(uint256 _deedId)
        external
        view
        mustBeValidDeed(_deedId)
        returns (string _deedUri)
    {
        _deedUri = "https://tenthousandsu.com/00000";
        bytes memory deedUriBytes = bytes(_deedUri);
        deedUriBytes[26] = byte(48+(_deedId / 10000) % 10);
        deedUriBytes[27] = byte(48+(_deedId / 1000) % 10);
        deedUriBytes[28] = byte(48+(_deedId / 100) % 10);
        deedUriBytes[29] = byte(48+(_deedId / 10) % 10);
        deedUriBytes[30] = byte(48+(_deedId / 1) % 10);
    }

    // COMPLIANCE WITH ERC721Enumerable (DRAFT) ////////////////////////////////

    /// @notice Enumerate active deeds
    /// @dev Throws if `_index` >= `countOfDeeds()`
    /// @param _index A counter less than `countOfDeeds()`
    /// @return The identifier for the `_index`th deed, (sort order not
    ///  specified)
    function deedByIndex(uint256 _index)
        external
        view
        returns (uint256 _deedId)
    {
        require (_index < _countOfDeeds);
        return _index + 1;
    }

    /// @notice Count of owners which own at least one deed
    /// @return A count of the number of owners which own deeds
    function countOfOwners() external view returns (uint256 _count) {
        return _owners.length;
    }

    /// @notice Enumerate owners
    /// @dev Throws if `_index` >= `countOfOwners()`
    /// @param _index A counter less than `countOfOwners()`
    /// @return The address of the `_index`th owner (sort order not specified)
    function ownerByIndex(uint256 _index) external view returns (address _owner) {
        return _owners[_index];
    }

    // INTERNAL FUNCTIONS //////////////////////////////////////////////////////

    modifier mustBeOwnedByThisContract(uint256 _deedId) {
        address owner = _ownerOfWithSubstitutions[_deedId];
        require(owner == address(0) || owner == address(this));
        _;
    }

    modifier mustBeValidDeed(uint256 _deedId) {
        require (_deedId >= 1 && _deedId <= _countOfDeeds);
        _;
    }

    /// @dev Actually do the transfer, does NO precondition checking
    function _transfer(uint256 _deedId, address _to) internal {
        // Find the FROM address
        // assert(mustBeValidDeed(_deedId))
        address fromWithSubstitution = _ownerOfWithSubstitutions[_deedId];
        address from = fromWithSubstitution;
        if (fromWithSubstitution == address(0)) {
            from = address(this);
        }

        // Take away from FROM address
        // How to delete from an unsorted array: move last item over it, trim
        if (_deedsOfOwnerWithSubstitutions[from].length > 1) {
            uint256 deedIndexToDeleteWithSubstitution = _indexOfDeedOfOwnerWithSubstitutions[_deedId];
            uint256 deedIndexToDelete;
            if (deedIndexToDeleteWithSubstitution == 0) {
                deedIndexToDelete = _deedId - 1;
            } else {
                deedIndexToDelete = deedIndexToDeleteWithSubstitution - 1;
            }
            uint256 deedToMove = _deedsOfOwnerWithSubstitutions[from][_deedsOfOwnerWithSubstitutions[from].length - 1];
            _deedsOfOwnerWithSubstitutions[from][deedIndexToDelete] = deedToMove;
            _deedsOfOwnerWithSubstitutions[from][_deedsOfOwnerWithSubstitutions[from].length - 1] = 0; // get gas back
            _indexOfDeedOfOwnerWithSubstitutions[deedToMove] = deedIndexToDelete + 1;
        } else {
            // assert(_owners.length > 1); If assertion is wrong, that means could be skipped with no loss of accuracy
            uint256 ownerIndexToDelete = _indexOfOwner[from];
            address ownerToMove = _owners[_owners.length - 1];
            _owners[ownerIndexToDelete] = ownerToMove;
            _owners[_owners.length - 1] = address(0); // get gas back
            _owners.length--;
        }
        _deedsOfOwnerWithSubstitutions[from].length--;
        // Right now _indexOfDeedOfOwnerWithSubstitutions[_deedId] is invalid, set it below

        // Give to TO address
        // assert(_to != address(0));
        // assert(_to != address(this));
        if (_deedsOfOwnerWithSubstitutions[_to].length == 0) {
            _owners.push(_to);
            _indexOfOwner[_to] = _owners.length - 1;
        }
        _deedsOfOwnerWithSubstitutions[_to].push(_deedId);
        _indexOfDeedOfOwnerWithSubstitutions[_deedId] = _deedsOfOwnerWithSubstitutions[_to].length; // [length - 1] is where you find it

        // External processing
        _ownerOfWithSubstitutions[_deedId] = _to;
        Transfer(from, _to, _deedId);
    }

    // PRIVATE DETAILS /////////////////////////////////////////////////////////

    function XXXXOwnership() public {
        _countOfDeeds = 1000000000;
        // for (uint256 i = 1; i <= _countOfDeeds; i++) {
        //     _ownerOfWithSubstitutions[i] = address(this);
        // }

        _deedsOfOwnerWithSubstitutions[address(this)].length = _countOfDeeds;
        // for (uint256 i = 0; i < _countOfDeeds; i++) {
        //     _deedsOfOwnerWithSubstitutions[address(this)][i] = i + 1;
        // }
        // for (uint256 i = 1; i <= _countOfDeeds; i++) {
        //     _indexOfDeedOfOwnerWithSubstitutions[i] = i - 1;
        // }

        _owners.push(address(this));
        _indexOfOwner[address(this)] = 0; // duh

    }

    uint256 private _countOfDeeds;

    /// @dev The owner of each deedId
    ///  If value == address(0), deed is owned by address(this)
    ///  If value != address(0), deed is owned by value
    ///  assert(This contract never assigns awnerhip to address(0) or destroys deeds)
    ///  See commented out code in constructor, saves hella gas
    mapping (uint256 => address) private _ownerOfWithSubstitutions;

    /// @dev The approved taker of each deedId
    mapping (uint256 => address) private _approvedOf;

    /// @dev The list of deeds each address owns
    ///  Nomenclature: var[key][index] = value
    ///  If key != address(this) or value != 0, then value represents a deedId
    ///  If key == address(this) and value == 0, then index + 1 is the deedId
    ///  assert(0 is not a valid deedId)
    ///  See commented out code in constructor, saves hella gas
    mapping (address => uint256[]) private _deedsOfOwnerWithSubstitutions;
    /// @dev Where each deed is in its owner's list
    ///  If value != 0, _deedsOfOwnerWithSubstitutions[owner][value - 1] = deedId
    ///  If value == 0, _deedsOfOwnerWithSubstitutions[owner][key - 1] = deedId
    ///  assert(_countOfDeeds + 1 > _countOfDeeds); // Disallow 2**256 - 1
    ///  See commented out code in constructor, saves hella gas
    mapping (uint256 => uint256) private _indexOfDeedOfOwnerWithSubstitutions;

    /// @dev The list of owners
    address[] private _owners;
    /// @dev Where each owner is in the list
    mapping (address => uint256) private _indexOfOwner;
}
