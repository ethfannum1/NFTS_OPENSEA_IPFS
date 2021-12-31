// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;


/* 
--------------------
ERC721Enumerable.sol
--------------------

La carpeta extensions contiene contratos que extienden la funcionalidad del estándar ERC721.
Estos contratos en la carpeta extensions heredan del contrato ERC721.sol y por tanto cumplen con su estándar, extendiendo además su funcionalidad.
Nosotros heredamos de uno de estos contratos que extienden el ERC721, con lo que nosotros:
- estamos heredando todas las funcionalidades del estándar ERC721
y
- más funcionalidades extras. 

ERC721Enumerable.sol comporta una serie de funcionalidades que tienen que ver con llevar un seguimiento de los tokens.
Por ejemplo: retornar un array con todos los IDs de los tokens que tiene una determinada address, etc.
Nosotros la función que vamos a utilizar es: tokenOfOwnerByIndex. 
*/
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


/*
-----------
Ownable.sol 
-----------

Tiene que ver con el tema de acceso a un contrato. 
Funciones de permiso de propietario.
*/
import "@openzeppelin/contracts/access/Ownable.sol";


// Contrato Ejemplo.
contract NtfEjm is ERC721Enumerable, Ownable {

    /*     
    Todos los tokens NFTs son un número en un contrato y que tienen asociado una metadata.

    Necesitamos una función que retorne una URL, generalmente de IPFS, en la cual está la metadata.
    La metadata generalmente se formatea en un objeto JSON.

    En esta URL la parte principal o dominio principal no cambia, sólo va cambiando la parte referente a cada token.
    Entonces vamos a guardar el dominio principal de esa URL en una variable de estado.
    */
    string public baseURI;                          // Parte constante de la URL.
                            
    mapping(uint256 => string) private _hashIPFS;   // Parte variable/cambiante de la URL para cada NFT. // Hashes.
                            
    // La URL completa para cada caso, para cada NFT es = baseURI + _hashIPFS.


    /* 
    Direcciones útiles:
    
    js.ipfs.io
    docs.opensea.io/docs/metadata-standards 
    */

    /* 
    Estructura de la metadata y ERC721 en opensea:

    8357ffd-opensea-nft-metadata.png 

    https://docs.opensea.io/docs/metadata-standards#metadata-structure
    */

   


    /* 
    - El constructor de este contrato Nfts recibe sus dos parámetros. 
    - Y además llama al constructor de su contrato heredado, que sería ERC721Enumerable, pero éste no tiene constructor, 
      sino que lo tiene su contrato padre ERC721 que es a quien finalmente se llama. 
      Ownable por su parte no tiene constructor.

    Se hace así, cuando heredamos contratos que tienen constructores con parámetros.
    */
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        // Se podría poner la URL base de Pinata, sin el hash del NFT. Pero escoge poner la URL base de la dirección IPFS.
        baseURI = "https://ipfs.io/ipfs/";
    }




    /* 
    Función de Minteo. 
    Mintear = Crear.

    Mintea n NFTs en la misma función. Tantos como hashes se manden como segundo parámetro.
    Y los crea con dueño la address del primer parámetro.    
    */
    function mint(address _to, string[] memory _hashes) public onlyOwner {
        // La función totalSupply, que pertenece a ERC721Enumerable.sol, devuelve cuántos tokens NFT hay = cuántos token NFT ya han sido minteados previamente.
        // Variable supply = cuántos token NFT ya han sido minteados previamente.
        uint256 supply = totalSupply();

        // Para el número i de tokens NFT nuevos a crear/mintear:
        for (uint256 i = 0; i < _hashes.length; i++) {
            // Mintear/Crear el token NFT.
            // La función _safeMint pertenece a ERC721.sol
            _safeMint(_to, supply + i);

            // Se guarda el hash de cada token NFT creado.
            _hashIPFS[supply + i] = _hashes[i];
        }
    }



    /* 
    Hallar todos los IDs de los tokens de una address dada.
    
    Devuelve un array de IDs.
    */
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        // Número total de tokens que tiene la address.
        uint256 ownerTokenCount = balanceOf(_owner); // balanceOf es una función de ERC721.sol

        // Crea un array de tamaño igual al número de tokens que tiene la address.
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        // Llena el array con los IDs de la address.
        for (uint256 i = 0; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i); // tokenOfOwnerByIndex es una función de ERC721Enumerable.sol
        }

        return(tokenIds);
    }



    /*
    Función que OpenSea llama para obtener la metadata.

    OpenSea tiene que saber cuál es la metadata de cada token para poder mostrarlo en pantalla. Por eso esta función.
    */ 
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        // Se requiere que el ID del token exista = que el token ya se haya minteado/creado.
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token. El token no existe."); // _exists es una función de ERC721.sol

        // Copiamos en esta variable local, la parte constante de la URL.
        string memory currentBaseURI = _baseURI();

        return(
            // Si las longitudes de: la parte constante de la URL, y, la parte variable (hash) de la URL, son mayores de 0, o sea:
            // si existen ambas: 
            (bytes(currentBaseURI).length > 0 && bytes(_hashIPFS[tokenId]).length > 0) 
            // Si la condición es verdadera: devolver la cadena completa concatenada:
            ? string(abi.encodePacked(currentBaseURI, _hashIPFS[tokenId]))
            // Si la condición es falsa: devolver la cadena vacía.  
            : "" 
        );
    }


    // Retorna el valor de la variable baseURI.
    function _baseURI() internal view virtual override returns (string memory) {
        return(baseURI);
    }


    /* 
    Si en un futuro el día de mañana, se cambiase el servidor backend, el dominio de alojamiento: 
    esta función cambia la parte común de la URL actualizándola a la nueva.
    */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

}

