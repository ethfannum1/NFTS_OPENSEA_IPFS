const Ntfs = artifacts.require("NtfEjm"); // Se pone NtfEjm que es el nombre del contrato en el código. No es el nombre del fichero .sol

module.exports = function (deployer) {
    // Se pone la variable (const) del contrato, y a continuación separados por comas, cada uno de los parámetros que recibe el constructor.
    deployer.deploy(Ntfs, 'miNFTS', 'NFTS'); // Estos parámetros son strings, y pongo dos cualquiera que me invento.
};
