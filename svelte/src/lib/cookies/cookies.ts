export function getCookies() {
    return Object.fromEntries(document.cookie
      .replace(" ", "")
      .split(";")
      .map((record) => {
        let i = record.indexOf("=");
        return [record.slice(0, i).trim(), record.slice(i+1, record.length).trim()]
      }));
}
