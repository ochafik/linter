import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'dart:collection';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/testing/ast_factory.dart';
import 'package:analyzer/src/generated/testing/element_factory.dart';
import 'package:analyzer/src/generated/testing/test_type_provider.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';

import 'package:unittest/unittest.dart';

/**
 * The class `AnalysisContextFactory` defines utility methods used to create analysis contexts
 * for testing purposes.
 */
class AnalysisContextFactory {
  static String _DART_MATH = "dart:math";

  static String _DART_INTERCEPTORS = "dart:_interceptors";

  static String _DART_JS_HELPER = "dart:_js_helper";

  /**
   * Create an analysis context that has a fake core library already resolved.
   *
   * @return the analysis context that was created
   */
  static AnalysisContextImpl contextWithCore() {
    AnalysisContextForTests context = new AnalysisContextForTests();
    return initContextWithCore(context);
  }

  /**
   * Create an analysis context that uses the given options and has a fake core library already
   * resolved.
   *
   * @param options the options to be applied to the context
   * @return the analysis context that was created
   */
  static AnalysisContextImpl contextWithCoreAndOptions(
      AnalysisOptions options) {
    AnalysisContextForTests context = new AnalysisContextForTests();
    context._internalSetAnalysisOptions(options);
    return initContextWithCore(context);
  }

  /**
   * Initialize the given analysis context with a fake core library already resolved.
   *
   * @param context the context to be initialized (not `null`)
   * @return the analysis context that was created
   */
  static AnalysisContextImpl initContextWithCore(AnalysisContextImpl context) {
    DirectoryBasedDartSdk sdk = new _AnalysisContextFactory_initContextWithCore(
        new JavaFile("/fake/sdk"));
    SourceFactory sourceFactory =
        new SourceFactory([new DartUriResolver(sdk), new FileUriResolver()]);
    context.sourceFactory = sourceFactory;
    AnalysisContext coreContext = sdk.context;
    //
    // dart:core
    //
    TestTypeProvider provider = new TestTypeProvider();
    CompilationUnitElementImpl coreUnit =
        new CompilationUnitElementImpl("core.dart");
    Source coreSource = sourceFactory.forUri(DartSdk.DART_CORE);
    coreContext.setContents(coreSource, "");
    coreUnit.source = coreSource;
    ClassElementImpl proxyClassElement = ElementFactory.classElement2("_Proxy");
    coreUnit.types = <ClassElement>[
      provider.boolType.element,
      provider.deprecatedType.element,
      provider.doubleType.element,
      provider.functionType.element,
      provider.intType.element,
      provider.iterableType.element,
      provider.iteratorType.element,
      provider.listType.element,
      provider.mapType.element,
      provider.nullType.element,
      provider.numType.element,
      provider.objectType.element,
      proxyClassElement,
      provider.stackTraceType.element,
      provider.stringType.element,
      provider.symbolType.element,
      provider.typeType.element
    ];
    coreUnit.functions = <FunctionElement>[
      ElementFactory.functionElement3("identical", provider.boolType.element,
          <ClassElement>[
        provider.objectType.element,
        provider.objectType.element
      ], null),
      ElementFactory.functionElement3("print", VoidTypeImpl.instance.element,
          <ClassElement>[provider.objectType.element], null)
    ];
    TopLevelVariableElement proxyTopLevelVariableElt = ElementFactory
        .topLevelVariableElement3("proxy", true, false, proxyClassElement.type);
    TopLevelVariableElement deprecatedTopLevelVariableElt = ElementFactory
        .topLevelVariableElement3(
            "deprecated", true, false, provider.deprecatedType);
    coreUnit.accessors = <PropertyAccessorElement>[
      proxyTopLevelVariableElt.getter,
      deprecatedTopLevelVariableElt.getter
    ];
    coreUnit.topLevelVariables = <TopLevelVariableElement>[
      proxyTopLevelVariableElt,
      deprecatedTopLevelVariableElt
    ];
    LibraryElementImpl coreLibrary = new LibraryElementImpl.forNode(
        coreContext, AstFactory.libraryIdentifier2(["dart", "core"]));
    coreLibrary.definingCompilationUnit = coreUnit;
    //
    // dart:async
    //
    CompilationUnitElementImpl asyncUnit =
        new CompilationUnitElementImpl("async.dart");
    Source asyncSource = sourceFactory.forUri(DartSdk.DART_ASYNC);
    coreContext.setContents(asyncSource, "");
    asyncUnit.source = asyncSource;
    // Future
    ClassElementImpl futureElement =
        ElementFactory.classElement2("Future", ["T"]);
    InterfaceType futureType = futureElement.type;
    //   factory Future.value([value])
    ConstructorElementImpl futureConstructor =
        ElementFactory.constructorElement2(futureElement, "value");
    futureConstructor.parameters = <ParameterElement>[
      ElementFactory.positionalParameter2("value", provider.dynamicType)
    ];
    futureConstructor.factory = true;
    (futureConstructor.type as FunctionTypeImpl).typeArguments =
        futureElement.type.typeArguments;
    futureElement.constructors = <ConstructorElement>[futureConstructor];
    //   Future then(onValue(T value), { Function onError });
    List<ParameterElement> parameters = <ParameterElement>[
      ElementFactory.requiredParameter2(
          "value", futureElement.typeParameters[0].type)
    ];
    FunctionTypeAliasElementImpl aliasElement =
        new FunctionTypeAliasElementImpl.forNode(null);
    aliasElement.synthetic = true;
    aliasElement.parameters = parameters;
    aliasElement.returnType = provider.dynamicType;
    aliasElement.enclosingElement = asyncUnit;
    FunctionTypeImpl aliasType = new FunctionTypeImpl.con2(aliasElement);
    aliasElement.shareTypeParameters(futureElement.typeParameters);
    aliasType.typeArguments = futureElement.type.typeArguments;
    MethodElement thenMethod = ElementFactory.methodElementWithParameters(
        "then", futureElement.type.typeArguments, futureType, [
      ElementFactory.requiredParameter2("onValue", aliasType),
      ElementFactory.namedParameter2("onError", provider.functionType)
    ]);
    futureElement.methods = <MethodElement>[thenMethod];
    // Completer
    ClassElementImpl completerElement =
        ElementFactory.classElement2("Completer", ["T"]);
    ConstructorElementImpl completerConstructor =
        ElementFactory.constructorElement2(completerElement, null);
    (completerConstructor.type as FunctionTypeImpl).typeArguments =
        completerElement.type.typeArguments;
    completerElement.constructors = <ConstructorElement>[completerConstructor];
    asyncUnit.types = <ClassElement>[
      completerElement,
      futureElement,
      ElementFactory.classElement2("Stream", ["T"])
    ];
    LibraryElementImpl asyncLibrary = new LibraryElementImpl.forNode(
        coreContext, AstFactory.libraryIdentifier2(["dart", "async"]));
    asyncLibrary.definingCompilationUnit = asyncUnit;
    //
    // dart:html
    //
    CompilationUnitElementImpl htmlUnit =
        new CompilationUnitElementImpl("html_dartium.dart");
    Source htmlSource = sourceFactory.forUri(DartSdk.DART_HTML);
    coreContext.setContents(htmlSource, "");
    htmlUnit.source = htmlSource;
    ClassElementImpl elementElement = ElementFactory.classElement2("Element");
    InterfaceType elementType = elementElement.type;
    ClassElementImpl canvasElement =
        ElementFactory.classElement("CanvasElement", elementType);
    ClassElementImpl contextElement =
        ElementFactory.classElement2("CanvasRenderingContext");
    InterfaceType contextElementType = contextElement.type;
    ClassElementImpl context2dElement = ElementFactory.classElement(
        "CanvasRenderingContext2D", contextElementType);
    canvasElement.methods = <MethodElement>[
      ElementFactory.methodElement(
          "getContext", contextElementType, [provider.stringType])
    ];
    canvasElement.accessors = <PropertyAccessorElement>[
      ElementFactory.getterElement("context2D", false, context2dElement.type)
    ];
    canvasElement.fields = canvasElement.accessors
        .map((PropertyAccessorElement accessor) => accessor.variable)
        .toList();
    ClassElementImpl documentElement =
        ElementFactory.classElement("Document", elementType);
    ClassElementImpl htmlDocumentElement =
        ElementFactory.classElement("HtmlDocument", documentElement.type);
    htmlDocumentElement.methods = <MethodElement>[
      ElementFactory.methodElement(
          "query", elementType, <DartType>[provider.stringType])
    ];
    htmlUnit.types = <ClassElement>[
      ElementFactory.classElement("AnchorElement", elementType),
      ElementFactory.classElement("BodyElement", elementType),
      ElementFactory.classElement("ButtonElement", elementType),
      canvasElement,
      contextElement,
      context2dElement,
      ElementFactory.classElement("DivElement", elementType),
      documentElement,
      elementElement,
      htmlDocumentElement,
      ElementFactory.classElement("InputElement", elementType),
      ElementFactory.classElement("SelectElement", elementType)
    ];
    htmlUnit.functions = <FunctionElement>[
      ElementFactory.functionElement3("query", elementElement,
          <ClassElement>[provider.stringType.element],
          ClassElementImpl.EMPTY_ARRAY)
    ];
    TopLevelVariableElementImpl document = ElementFactory
        .topLevelVariableElement3(
            "document", false, true, htmlDocumentElement.type);
    htmlUnit.topLevelVariables = <TopLevelVariableElement>[document];
    htmlUnit.accessors = <PropertyAccessorElement>[document.getter];
    LibraryElementImpl htmlLibrary = new LibraryElementImpl.forNode(
        coreContext, AstFactory.libraryIdentifier2(["dart", "dom", "html"]));
    htmlLibrary.definingCompilationUnit = htmlUnit;
    //
    // dart:math
    //
    CompilationUnitElementImpl mathUnit =
        new CompilationUnitElementImpl("math.dart");
    Source mathSource = sourceFactory.forUri(_DART_MATH);
    coreContext.setContents(mathSource, "");
    mathUnit.source = mathSource;
    FunctionElement cosElement = ElementFactory.functionElement3("cos",
        provider.doubleType.element, <ClassElement>[provider.numType.element],
        ClassElementImpl.EMPTY_ARRAY);
    TopLevelVariableElement ln10Element = ElementFactory
        .topLevelVariableElement3("LN10", true, false, provider.doubleType);
    TopLevelVariableElement piElement = ElementFactory.topLevelVariableElement3(
        "PI", true, false, provider.doubleType);
    ClassElementImpl randomElement = ElementFactory.classElement2("Random");
    randomElement.abstract = true;
    ConstructorElementImpl randomConstructor =
        ElementFactory.constructorElement2(randomElement, null);
    randomConstructor.factory = true;
    ParameterElementImpl seedParam = new ParameterElementImpl("seed", 0);
    seedParam.parameterKind = ParameterKind.POSITIONAL;
    seedParam.type = provider.intType;
    randomConstructor.parameters = <ParameterElement>[seedParam];
    randomElement.constructors = <ConstructorElement>[randomConstructor];
    FunctionElement sinElement = ElementFactory.functionElement3("sin",
        provider.doubleType.element, <ClassElement>[provider.numType.element],
        ClassElementImpl.EMPTY_ARRAY);
    FunctionElement sqrtElement = ElementFactory.functionElement3("sqrt",
        provider.doubleType.element, <ClassElement>[provider.numType.element],
        ClassElementImpl.EMPTY_ARRAY);
    mathUnit.accessors = <PropertyAccessorElement>[
      ln10Element.getter,
      piElement.getter
    ];
    mathUnit.functions = <FunctionElement>[cosElement, sinElement, sqrtElement];
    mathUnit.topLevelVariables = <TopLevelVariableElement>[
      ln10Element,
      piElement
    ];
    mathUnit.types = <ClassElement>[randomElement];
    LibraryElementImpl mathLibrary = new LibraryElementImpl.forNode(
        coreContext, AstFactory.libraryIdentifier2(["dart", "math"]));
    mathLibrary.definingCompilationUnit = mathUnit;
    //
    // Set empty sources for the rest of the libraries.
    //
    Source source = sourceFactory.forUri(_DART_INTERCEPTORS);
    coreContext.setContents(source, "");
    source = sourceFactory.forUri(_DART_JS_HELPER);
    coreContext.setContents(source, "");
    //
    // Record the elements.
    //
    HashMap<Source, LibraryElement> elementMap =
        new HashMap<Source, LibraryElement>();
    elementMap[coreSource] = coreLibrary;
    elementMap[asyncSource] = asyncLibrary;
    elementMap[htmlSource] = htmlLibrary;
    elementMap[mathSource] = mathLibrary;
    context.recordLibraryElements(elementMap);
    return context;
  }
}

/**
 * Instances of the class `AnalysisContextForTests` implement an analysis context that has a
 * fake SDK that is much smaller and faster for testing purposes.
 */
class AnalysisContextForTests extends AnalysisContextImpl {
  @override
  void set analysisOptions(AnalysisOptions options) {
    AnalysisOptions currentOptions = analysisOptions;
    bool needsRecompute = currentOptions.analyzeFunctionBodiesPredicate !=
            options.analyzeFunctionBodiesPredicate ||
        currentOptions.generateImplicitErrors !=
            options.generateImplicitErrors ||
        currentOptions.generateSdkErrors != options.generateSdkErrors ||
        currentOptions.dart2jsHint != options.dart2jsHint ||
        (currentOptions.hint && !options.hint) ||
        currentOptions.preserveComments != options.preserveComments ||
        currentOptions.enableStrictCallChecks != options.enableStrictCallChecks;
//    if (needsRecompute) {
//      fail(
//          "Cannot set options that cause the sources to be reanalyzed in a test context");
//    }
    super.analysisOptions = options;
  }

  @override
  bool exists(Source source) =>
      super.exists(source) || sourceFactory.dartSdk.context.exists(source);

  @override
  TimestampedData<String> getContents(Source source) {
    if (source.isInSystemLibrary) {
      return sourceFactory.dartSdk.context.getContents(source);
    }
    return super.getContents(source);
  }

  @override
  int getModificationStamp(Source source) {
    if (source.isInSystemLibrary) {
      return sourceFactory.dartSdk.context.getModificationStamp(source);
    }
    return super.getModificationStamp(source);
  }

  /**
   * Set the analysis options, even if they would force re-analysis. This method should only be
   * invoked before the fake SDK is initialized.
   *
   * @param options the analysis options to be set
   */
  void _internalSetAnalysisOptions(AnalysisOptions options) {
    super.analysisOptions = options;
  }
}

class _AnalysisContextFactory_initContextWithCore
    extends DirectoryBasedDartSdk {
  _AnalysisContextFactory_initContextWithCore(JavaFile arg0) : super(arg0);

  @override
  LibraryMap initialLibraryMap(bool useDart2jsPaths) {
    LibraryMap map = new LibraryMap();
    _addLibrary(map, DartSdk.DART_ASYNC, false, "async.dart");
    _addLibrary(map, DartSdk.DART_CORE, false, "core.dart");
    _addLibrary(map, DartSdk.DART_HTML, false, "html_dartium.dart");
    _addLibrary(map, AnalysisContextFactory._DART_MATH, false, "math.dart");
    _addLibrary(map, AnalysisContextFactory._DART_INTERCEPTORS, true,
        "_interceptors.dart");
    _addLibrary(
        map, AnalysisContextFactory._DART_JS_HELPER, true, "_js_helper.dart");
    return map;
  }

  void _addLibrary(LibraryMap map, String uri, bool isInternal, String path) {
    SdkLibraryImpl library = new SdkLibraryImpl(uri);
    if (isInternal) {
      library.category = "Internal";
    }
    library.path = path;
    map.setLibrary(uri, library);
  }
}
