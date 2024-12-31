//
//  DrawingOperations.swift
//  Drawsana
//
//  Created by Steve Landey on 8/6/18.
//  Copyright © 2018 Asana. All rights reserved.
//

import CoreGraphics

/**
 Add a shape to the drawing. Undoing removes the shape.
 */
public struct AddShapeOperation: DrawingOperation {
    private enum CodingKeys: String, CodingKey {
      case shape
    }
  let shape: Shape

  public init(shape: Shape) {
    self.shape = shape
  }

  public func apply(drawing: Drawing) {
    drawing.add(shape: shape)
  }

  public func revert(drawing: Drawing) {
    drawing.remove(shape: shape)
  }
  public var currentShape:Shape{
        return shape;
   }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shape, forKey:.shape)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        var tempShape:Shape!
        if let shape = try? values.decode(EllipseShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(LineShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(NgonShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(PenShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(RectShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(StarShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(TextShape.self, forKey:.shape){
            tempShape=shape
        }
        self.shape=tempShape
    }
}

/**
 Remove a shape from the drawing. Undoing adds the shape back.
 */
public struct RemoveShapeOperation: DrawingOperation {
    private enum CodingKeys: String, CodingKey {
      case shape
    }
  let shape: Shape

  public init(shape: Shape) {
    self.shape = shape
  }

  public func apply(drawing: Drawing) {
    drawing.remove(shape: shape)
  }

  public func revert(drawing: Drawing) {
    drawing.add(shape: shape)
  }
    public var currentShape:Shape{
          return shape;
     }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shape, forKey:.shape)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var tempShape:Shape!
        if let shape = try? values.decode(EllipseShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(LineShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(NgonShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(PenShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(RectShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(StarShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(TextShape.self, forKey:.shape){
            tempShape=shape
        }
        self.shape=tempShape
    }
}

/**
 Change the transform of a `ShapeWithTransform`. Undoing sets its transform
 back to its original value.
 */
public struct ChangeTransformOperation: DrawingOperation {
    public enum CodingKeys: String, CodingKey {
      case shape,transform, originalTransform
    }
    
    
    var shape: ShapeWithTransform
  let transform: ShapeTransform
  let originalTransform: ShapeTransform

  public init(shape: ShapeWithTransform, transform: ShapeTransform, originalTransform: ShapeTransform) {
    self.shape = shape
    self.transform = transform
    self.originalTransform = originalTransform
  }

  public func apply(drawing: Drawing) {
    shape.transform = transform
    drawing.update(shape: shape)
  }

  public func revert(drawing: Drawing) {
    shape.transform = originalTransform
    drawing.update(shape: shape)
  }
    
    public var currentShape:Shape{
          return shape;
     }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shape, forKey:.shape)
        try container.encode(self.originalTransform, forKey:.originalTransform)
        try container.encode(self.transform, forKey:.transform)

    }
//    func valuee(decoder: Decoder,_ key:CodingKeys)->Shape?{
//        typealias shapeType = (AnyObject&Decodable).Type
//        let values = try? decoder.container(keyedBy: CodingKeys.self)
//        let classs:[shapeType] = [AngleShape.self,
//        EllipseShape.self,
//        LineShape.self,
//        NgonShape.self,
//        PenShape.self,
//        RectShape.self,
//        StarShape.self,
//        TextShape.self]
//
//        for  classItem in classs{
//            return try? values?.decode(classItem, forKey:key)
//        }
//        return nil
//    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.transform = try values.decode(ShapeTransform.self, forKey:.transform)
        self.originalTransform = try values.decode(ShapeTransform.self, forKey:.originalTransform)
        var tempShape:ShapeWithTransform!
        if let shape = try? values.decode(EllipseShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(LineShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(NgonShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(PenShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(RectShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(StarShape.self, forKey:.shape){
            tempShape=shape
        }else
        if let shape = try? values.decode(TextShape.self, forKey:.shape){
            tempShape=shape
        }
        self.shape=tempShape
    }
}

/**
 Edit the text of a `TextShape`. Undoing sets the text back to the original
 value.

 If this operation immediately follows an `AddShapeOperation` for the exact
 same text shape, and `originalText` is empty, then this operation declines to
 be added to the undo stack and instead causes the `AddShapeOperation` to simply
 add the shape with the new text value. This means that we avoid having an
 "add empty text shape" operation in the undo stack.
 */
public struct EditTextOperation: DrawingOperation {
    private enum CodingKeys: String, CodingKey {
      case shape,originalText, text
    }
    
  let shape: TextShape
  let originalText: String
  let text: String
    
    public var currentShape:Shape{
          return shape;
     }
    
  public init(
    shape: TextShape,
    originalText: String,
    text: String)
  {
    self.shape = shape
    self.originalText = originalText
    self.text = text
  }

  public func shouldAdd(to operationStack: DrawingOperationStack) -> Bool {
    if originalText.isEmpty,
      let addShapeOp = operationStack.undoStack.last as? AddShapeOperation,
      addShapeOp.shape === shape
    {
      // It's pointless to let the user undo to an empty text shape. By setting
      // the shape text immediately and then declining to be added to the stack,
      // the add-shape operation ends up adding/removing the shape with the
      // correct text on its own.
      shape.text = text
      return false
    } else {
      return true
    }
  }

  public func apply(drawing: Drawing) {
    shape.text = text
    drawing.update(shape: shape)
  }

  public func revert(drawing: Drawing) {
    shape.text = originalText
    drawing.update(shape: shape)
  }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shape, forKey:.shape)
        try container.encode(self.originalText, forKey:.originalText)
        try container.encode(self.text, forKey:.text)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.shape = try values.decode(TextShape.self, forKey:.shape)
        self.originalText = try values.decode(String.self, forKey: .originalText)
        self.text = try values.decode(String.self, forKey: .text)
    }
}

/**
 Change the user-specified width of a text shape
 */
public struct ChangeExplicitWidthOperation: DrawingOperation {
    private enum CodingKeys: String, CodingKey {
      case shape,originalWidth, originalBoundingRect,newWidth,newBoundingRect
    }
  let shape: TextShape
  let originalWidth: CGFloat?
  let originalBoundingRect: CGRect
  let newWidth: CGFloat?
  let newBoundingRect: CGRect
    
    public var currentShape:Shape{
          return shape;
     }
    
  init(
    shape: TextShape,
    originalWidth: CGFloat?,
    originalBoundingRect: CGRect,
    newWidth: CGFloat?,
    newBoundingRect: CGRect)
  {
    self.shape = shape
    self.originalWidth = originalWidth
    self.originalBoundingRect = originalBoundingRect
    self.newWidth = newWidth
    self.newBoundingRect = newBoundingRect
  }

  public func apply(drawing: Drawing) {
    shape.explicitWidth = newWidth
    shape.boundingRect = newBoundingRect
    drawing.update(shape: shape)
  }

  public func revert(drawing: Drawing) {
    shape.explicitWidth = originalWidth
    shape.boundingRect = originalBoundingRect
    drawing.update(shape: shape)
  }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shape, forKey:.shape)
        try container.encode(self.originalWidth, forKey:.originalWidth)
        try container.encode(self.originalBoundingRect, forKey:.originalBoundingRect)
        try container.encode(self.newWidth, forKey:.newWidth)
        try container.encode(self.newBoundingRect, forKey:.newBoundingRect)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.shape = try values.decode(TextShape.self, forKey:.shape)
        originalBoundingRect = try values.decode(CGRect.self, forKey: .originalBoundingRect)
        newBoundingRect = try values.decode(CGRect.self, forKey: .newBoundingRect)
        originalWidth = try values.decode(CGFloat.self, forKey: .originalWidth)
        newWidth = try values.decode(CGFloat.self, forKey: .newWidth)
    }
}

