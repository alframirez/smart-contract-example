// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AcuerdoDePago {
    address payable public vendedor;
    address payable public comprador;
    uint256 public precio;
    bool public pagado;
    bool public servicioRealizadoPorComprador;

    constructor(address payable _vendedor, uint256 _precio) {
        vendedor = _vendedor;
        precio = _precio;
    }

    function comprar() public payable {
        require(!pagado, "El pago ya ha sido realizado");
        require(
            msg.value == precio,
            "La cantidad enviada no es la misma que el precio acordado"
        );
        comprador = payable(msg.sender);
        pagado = true;
    }

    function confirmarServicioRealizado() public {
        require(
            msg.sender == comprador,
            "Solo el comprador puede confirmar el servicio realizado"
        );
        require(pagado, "El pago aun no se ha realizado");
        if (comprador == msg.sender) {
            servicioRealizadoPorComprador = true;
        }
        if (servicioRealizadoPorComprador) {
            vendedor.transfer(address(this).balance);
        }
    }
}
