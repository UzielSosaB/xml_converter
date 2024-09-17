class Comprobante {
  late DateTime fecha;
  late String serie;
  late String folio;
  late String uuid;
  late String rfcReceptor;
  late String nombreReceptor;
  late String rfcEmisor;
  late String nombreEmisor;
  late String moneda;
  late List<Concepto> conceptos;

  Comprobante({
    required this.fecha,
    required this.serie,
    required this.folio,
    required this.uuid,
    required this.rfcReceptor,
    required this.nombreReceptor,
    required this.rfcEmisor,
    required this.nombreEmisor,
    required this.moneda,
    required this.conceptos,
  });

  // Puedes agregar métodos adicionales si es necesario
}

class Concepto {
  late String descripcion;
  late double subTotal;
  late double descuento;
  late double total;
  late Impuesto impuestos;
  late List<double> impuestosPorcentaje;
  late List<double> impuestosTotal;
  late List<double> totalIVATrasladado;
  late List<double> totalISRRetenido;
  late List<double> totalIVARetenido;
  late List<double> totalIEPSTrasladado;

  Concepto({
    required this.descripcion,
    required this.subTotal,
    required this.descuento,
    required this.total,
    required this.impuestos,
    required this.impuestosPorcentaje,
    required this.impuestosTotal,
    required this.totalIVATrasladado,
    required this.totalISRRetenido,
    required this.totalIVARetenido,
    required this.totalIEPSTrasladado,
  });

  // Métodos adicionales para cálculos específicos o validaciones pueden ir aquí
}

class Impuesto {
  late List<TipoImpuesto> traslado;
  late List<TipoImpuesto> retencion;

  Impuesto({
    required this.traslado,
    required this.retencion,
  });

  // Métodos para manejar impuestos, cálculos, etc. pueden ser añadidos aquí
}

class TipoImpuesto {
  late double base;
  late double importe;
  late String impuesto;
  late double tasaOCuota;
  late String tipoFactor;

  TipoImpuesto({
    required this.base,
    required this.impuesto,
    required this.tipoFactor,
    required this.tasaOCuota,
    required this.importe,
  });

  // Métodos para manipular información del impuesto pueden ir aquí
}

class ObjetoImpuestos {
  final Map<String, String> impuestosTraslados = {
    '002': 'IVA',
    '003': 'IEPS',
    '99': 'Otros',
  };

  final Map<String, String> impuestosRetenidos = {
    '001': 'RET. ISR',
    '002': 'RET. IVA',
    '003': 'RET. IEPS',
    '99': 'Otros',
  };

  // Métodos para manipular los mapas de impuestos pueden ser añadidos aquí
}
