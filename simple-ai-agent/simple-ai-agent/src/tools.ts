import { documents } from "./documents.js";

export function search_documents(query: string) {
  const words = query.toLowerCase().split(/\W+/).filter(word => word.length > 3);

  return documents
    .filter(doc => {
      const text = (doc.title + " " + doc.content).toLowerCase();
      return words.some(word => text.includes(word));
    })
    .map(doc => ({ id: doc.id, title: doc.title }));
}

export function get_document(id: string) {
  const doc = documents.find(doc => doc.id === id);

  if (!doc) {
    throw new Error("Document not found");
  }

  return doc;
}
